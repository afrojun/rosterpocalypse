class GameStatsIngestionService

  class << self

    def populate_from_json json
      if json
        ActiveRecord::Base.transaction do
          map = Map.find_or_create_by name: json["map_name"]
          game = Game.find_or_create_by game_hash: json["unique_id"] do |g|
                   g.map_id = map.id
                   g.start_date = Time.at(json["start_epoch_time_utc"]).utc.to_datetime
                   g.duration_s = json["duration"]
                 end

          # Many games have player names that include a team name prefix, we need to
          # detect the name so we can strip it from player names.
          # First, split the player details by team colour so we can look at the players
          # in each team separately
          player_details_by_team_colour = get_player_details_by_team_colour json["player_details"]
          team_name_prefix_by_colour = get_team_name_prefix_by_team_colour player_details_by_team_colour
          team_names_by_colour = get_team_names_by_team_colour_from_filename json["filename"], team_name_prefix_by_colour, player_details_by_team_colour

          player_details_by_team_colour.each do |team_colour, player_details|
            # Detect the team name as follows:
            # 1. If we are able to detect team names from the filename, use those
            # 2. If not, use the team name prefix if available
            # 3. Finally, if both above options fail, use the team name "Unknown"
            team_name = if team_names_by_colour[team_colour].present?
                          team_names_by_colour[team_colour]
                        else
                          team_name_prefix_by_colour[team_colour].present? ? team_name_prefix_by_colour[team_colour] : "Unknown"
                        end

            team = Team.find_or_create_including_alternate_names team_name

            player_details.each do |player_detail|
              # If the team name is prefixed to player names, strip it out
              sanitized_player_name = strip_team_name_prefix_from_player_name team_name_prefix_by_colour[team_colour], player_detail["name"]

              player = Player.find_or_create_including_alternate_names sanitized_player_name

              # Update the player's team if:
              # 1. the player's team is not yet defined
              # 2. the player's team name is "Unknown" OR the imported game is newer than the most recent previously imported game
              #
              # Otherwise update the current team to the player's team if the team name is "Unknown"
              most_recent_game = player.games.order(start_date: :desc).first
              if player.team.blank? || (team.name != "Unknown" && (player.team.name == "Unknown" || game.start_date > most_recent_game.start_date))
                player.update_attribute(:team, team)
              else
                team = player.team if team.name == "Unknown" && player.team.name != "Unknown"
              end

              hero = Hero.find_or_create_by internal_name: player_detail["hero"] do |h|
                       if hero_details = Hero::HEROES[player_detail["hero"]]
                         h.name = hero_details[:name]
                         h.classification = hero_details[:classification]
                       else
                        h.name = player_detail["hero"]
                      end
                     end

              game_detail = GameDetail.find_or_initialize_by player: player, game: game
              game_detail.update_attributes!(
                hero: hero,
                team: team,
                solo_kills: player_detail["SoloKill"],
                assists: player_detail["Assists"],
                deaths: player_detail["Deaths"],
                time_spent_dead: player_detail["TimeSpentDead"],
                team_colour: team_colour,
                win: player_detail["result"] == "win" ? true : false
              )
            end
          end
        end
      else
        Rails.logger.warn "No json input provided!"
      end
    end

    protected

    def get_team_name_prefix_by_team_colour player_details_by_team
      Hash.new.tap do |team_name_prefix_by_team|
        player_details_by_team.each do |team, player_details|
          player_names = player_details.map { |player_detail| player_detail["name"] }
          team_name = get_team_name_prefix player_names
          team_name_prefix_by_team[team] = team_name
        end
      end
    end

    def get_team_names_by_team_colour_from_filename filename, team_name_prefix_by_colour, player_details_by_team_colour
      basename = File.basename filename
      result = basename.match /^\d\d\.\d\d\.\d\d_([\w-]+)_vs_([\w-]+)_GAME_\d_at_(\w+)\.StormReplay$/
      if result && result.size == 4
        # We try to match the team names to colours based on the prefix and players in the team, but if that fails, we just guess the team colours
        _, team1, team2, tournament = result.to_a
        team_name1 = team1.gsub("_", " ")
        team_name2 = team2.gsub("_", " ")

        if (match_team_name?(team_name1, team_name_prefix_by_colour["red"], player_details_by_team_colour["red"]) ||
            match_team_name?(team_name2, team_name_prefix_by_colour["blue"], player_details_by_team_colour["blue"]))
          {
            "red" => team_name1,
            "blue" => team_name2
          }
        else
          {
            "blue" => team_name1,
            "red" => team_name2
          }
        end
      else
        {
          "red" => "",
          "blue" => ""
        }
      end
    end

    def match_team_name? full_name, abbreviation, player_details
      team_name_match = fuzzy_match_team_name(full_name, abbreviation)
      return team_name_match.present? if team_name_match.present?

      players_in_team? full_name, player_details
    end

    def players_in_team? team_name, player_details
      # Use Player names to try to match the team name
      player_names = player_details.map { |detail| detail["name"] }

      team = Team.where(name: team_name).first
      if team.present?
        team.players.any? { |player| player_names.include? player.name }
      else
        false
      end
    end

    def fuzzy_match_team_name full_name, abbreviation
      lowercase_name = full_name.downcase
      # The "Team" prefix in many team names can cause issues with this matching, so we need to handle it separately
      if lowercase_name.start_with? "team"
        lowercase_name.match(abbreviation.downcase.chars.join('.*')).to_s
      else
        lowercase_name.match("^" + abbreviation.downcase.chars.join('.*')).to_s
      end
    end

    def get_player_details_by_team_colour player_details
      Hash.new.tap do |player_details_by_team|
        player_details.each do |_, player_detail|
          if player_names = player_details_by_team[player_detail["team"]]
            player_names << player_detail
          else
            player_details_by_team[player_detail["team"]] = [player_detail]
          end
        end
      end
    end

    def get_team_name_prefix player_names
      first_name = player_names.first

      first_name.each_char.with_index do |char, idx|
        player_names.each do |player_name|
          return first_name[0, idx] if player_name[idx] != char
        end
      end

      return first_name
    end

    def strip_team_name_prefix_from_player_name team_name_prefix, player_name
      player_name.dup.tap do |name|
        name.slice!(team_name_prefix) if team_name_prefix.present?
      end
    end

  end

end