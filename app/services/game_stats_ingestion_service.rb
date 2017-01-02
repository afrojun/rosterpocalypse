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
          player_details_by_team = get_player_details_by_team json["player_details"]
          team_name_prefix_by_team = get_team_name_prefix_by_team player_details_by_team

          player_details_by_team.each do |team_colour, player_details|
            team_name = team_name_prefix_by_team[team_colour].present? ? team_name_prefix_by_team[team_colour] : "Unknown"
            team = Team.find_or_create_including_alternate_names team_name

            player_details.each do |player_detail|
              sanitized_player_name = strip_team_name_from_player_name team.name, player_detail["name"]

              player = Player.find_or_create_including_alternate_names sanitized_player_name

              if player.team.blank? || (team.name != "Unknown" && player.team.name == "Unknown")
                player.update_attribute(:team, team)
              else
                team = player.team if team.name == "Unknown"
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

    def get_team_name_prefix_by_team player_details_by_team
      Hash.new.tap do |team_name_prefix_by_team|
        player_details_by_team.each do |team, player_details|
          player_names = player_details.map { |player_detail| player_detail["name"] }
          team_name = get_team_name_prefix player_names
          team_name_prefix_by_team[team] = team_name
        end
      end
    end

    def get_player_details_by_team player_details
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

    def strip_team_name_from_player_name team_name, player_name
      player_name.dup.tap do |name|
        name.slice!(team_name)
      end
    end

  end

end