class GameStatsIngestionService
  FILENAME_FORMAT_REGEX = /^\d{2}\.\d{2}\.\d{2}_(.+)_vs_(.+)_game_\d_at_(.+)\.StormReplay$/

  private

  # Lazy loaded attributes
  attr_reader :start_date, :map, :game, :tournament, :gameweek, :tournament_name, :region, :filename_regex_match,
              :team_name_prefix_by_team_colour, :team_names_by_team_colour, :player_details_by_team_colour

  public

  attr_accessor :json, :create_or_update_models

  def initialize(json, create_or_update_models = false)
    @json = json
    @create_or_update_models = create_or_update_models
  end

  def populate_from_json
    if json && json["unique_id"] && Game.where(game_hash: json["unique_id"]).blank?
      ActiveRecord::Base.transaction do
        # Find or create the Map, Game and Tournament
        map
        tournament
        game

        player_details_by_team_colour.each do |team_colour, player_details|
          team = find_or_create_team team_colour

          player_details.each do |player_detail|
            hero = find_or_create_hero player_detail["hero"]
            player = find_or_create_player player_detail["name"], hero, team_colour

            # Update the player's team if:
            # 1. the player's team is not yet defined
            # 2. the player's team name is "Unknown" OR (the team name is not "Unknown" AND the imported game is newer than the most recent previously imported game)
            #
            # Otherwise update the current team to the player's team if the team name is "Unknown"
            most_recent_game = player.games.order(start_date: :desc).first
            if player.team.blank? || (team.name != "Unknown" && (player.team.name == "Unknown" || (most_recent_game && (game.start_date > most_recent_game.start_date))))
              player.update team: team
            elsif team.name == "Unknown" && player.team.name != "Unknown"
              team = player.team
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

        Rails.logger.info "Successfully added all game details."

        GameweekPlayer.update_from_game(game, gameweek) if gameweek.present?

        # The last step is to add the game to a Match
        Match.add_game game
      end

      game
    else
      Rails.logger.warn "No json input provided, or this game has already been ingested."
      nil
    end
  end

  private

  def start_date
    @start_date ||= Time.at(json["start_epoch_time_utc"]).utc.to_datetime
  end

  def map
    @map ||= Map.find_or_create_by name: json["map_name"]
  end

  def game
    @game ||= Game.find_or_create_by game_hash: json["unique_id"] do |g|
      g.map = map
      g.start_date = start_date
      g.duration_s = json["duration"]
      g.gameweek = gameweek
    end
  end

  def tournament
    @tournament ||= begin
      if tournament_name.present?
        tnmnt = Tournament.find_or_create_by name: tournament_name do |t|
          t.region = region
          t.cycle_hours = 24
          t.start_date = start_date.beginning_of_day
          t.end_date = start_date.end_of_day
        end

        # Update the start and end dates of the tournament if the game's start_date is out of bounds
        tnmnt.update(start_date: start_date.beginning_of_day) if start_date < tnmnt.start_date
        tnmnt.update(end_date: start_date.end_of_day) if start_date > tnmnt.end_date
        tnmnt
      else
        Rails.logger.warn "Unable to infer the tournament for this game."
        nil
      end
    end
  end

  def gameweek
    @gameweek ||= begin
      if tournament.present?
        tournament.gameweeks.where('start_date <= ? AND end_date >= ?', start_date, start_date).first
      end
    end
  end

  def find_or_create_team(team_colour)
    if create_or_update_models
      Team.find_or_create_including_alternate_names(team_name(team_colour)).tap do |team|
        TeamAlternateName.find_or_create_by(team: team, alternate_name: team_name_prefix_by_team_colour[team_colour]) if team_name_prefix_by_team_colour[team_colour].present?
        team.update(region: region) if team.region.blank? && region != Tournament::GLOBAL_REGION
      end
    else
      Team.find_including_alternate_names(team_name(team_colour)).first
    end
  end

  def find_or_create_player(player_name, hero, team_colour)
    # If the team name is prefixed to player names, strip it out
    sanitized_player_name = strip_team_name_prefix_from_player_name team_name_prefix_by_team_colour[team_colour], player_name

    if create_or_update_models
      Player.find_or_create_including_alternate_names(sanitized_player_name).tap do |player|
        player.set_role_from_class(hero.classification) if player.role.blank?
      end
    else
      Player.find_including_alternate_names(sanitized_player_name).first
    end
  end

  def find_or_create_hero(hero_name)
    if create_or_update_models
      Hero.find_or_create_by internal_name: hero_name do |h|
        if (hero_details = Hero::HEROES[hero_name])
          h.name = hero_details[:name]
          h.classification = hero_details[:classification]
        else
          h.name = hero_name
        end
      end
    else
      Hero.where(internal_name: hero_name).first
    end
  end

  def tournament_name
    @tournament_name ||= begin
      if filename_regex_match && filename_regex_match.size == 4
        tournament_name = filename_regex_match.to_a.last.tr("_", " ")

        # Sometimes the tournament name has some extra characters at the end of it, try to remove them if we can
        unless Tournament.where(name: tournament_name).any?
          alternate_name = tournament_name.split(" ").tap(&:pop).join(" ")
          tournament_name = alternate_name if Tournament.where(name: alternate_name).any?
        end

        tournament_name
      else
        ""
      end
    end
  end

  def region
    @region ||= begin
      if tournament_name
        regions = {
          "CN" => %w[China Gold\ Series],
          "EU" => %w[Europe Valencia Tours ZOTAC],
          "KR" => %w[Korea Super\ League],
          "NA" => %w[North\ America Austin Bloodlust]
        }
        regions.detect(-> { [Tournament::GLOBAL_REGION] }) do |region, keywords|
          tournament_name.include?(region) || keywords.any? { |keyword| tournament_name.include?(keyword) }
        end.first
      else
        ""
      end
    end
  end

  def basename
    File.basename json["filename"]
  end

  def filename_regex_match
    @filename_regex_match ||= basename.match FILENAME_FORMAT_REGEX
  end

  # Detect the team name as follows:
  # 1. If we are able to detect team names from the filename, use those
  # 2. If not, use the team name prefix if available
  # 3. Finally, if both above options fail, use the team name "Unknown"
  def team_name(team_colour)
    if team_names_by_team_colour[team_colour].present?
      team_names_by_team_colour[team_colour]
    else
      Rails.logger.warn "Unable to get figure out the full team names, falling back to name prefix or Unknown"
      team_name_prefix_by_team_colour[team_colour].present? ? team_name_prefix_by_team_colour[team_colour] : "Unknown"
    end
  end

  # Many games have player names that include a team name prefix, we need to
  # detect the name so we can strip it from player names.
  # First, split the player details by team colour so we can look at the players
  # in each team separately
  def team_name_prefix_by_team_colour
    @team_name_prefix_by_team_colour ||= begin
      {}.tap do |team_name_prefix_by_team|
        player_details_by_team_colour.each do |team, player_details|
          player_names = player_details.map { |player_detail| player_detail["name"] }
          team_name = team_name_prefix player_names
          team_name_prefix_by_team[team] = team_name
        end
      end
    end
  end

  def team_names_by_team_colour
    @team_names_by_team_colour ||= begin
      if filename_regex_match && filename_regex_match.size == 4
        # We try to match the team names to colours based on the prefix and players in the team, but if that fails, we just guess the team colours
        _, team_name1, team_name2, = filename_regex_match.to_a.map { |val| val.tr("_", " ") }

        if match_team_name?(team_name1, team_name_prefix_by_team_colour["red"], player_details_by_team_colour["red"]) ||
           match_team_name?(team_name2, team_name_prefix_by_team_colour["blue"], player_details_by_team_colour["blue"])
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
        Rails.logger.warn "Guessing team colour->name mapping for #{basename}."
        {
          "red" => "",
          "blue" => ""
        }
      end
    end
  end

  def player_details_by_team_colour
    @player_details_by_team_colour ||= begin
      {}.tap do |player_details_by_team|
        json["player_details"].each do |_, player_detail|
          if (player_names = player_details_by_team[player_detail["team"]])
            player_names << player_detail
          else
            player_details_by_team[player_detail["team"]] = [player_detail]
          end
        end
      end
    end
  end

  def match_team_name?(full_name, abbreviation, player_details)
    team_name_match = fuzzy_match_name(full_name, abbreviation)
    return team_name_match.present? if team_name_match.present?

    players_in_team? full_name, player_details
  end

  def players_in_team?(team_name, player_details)
    # Use Player names to try to match the team name
    player_names = player_details.map { |detail| detail["name"] }

    team = TeamAlternateName.where(alternate_name: team_name).first.try :team
    if team.present?
      team.players.any? { |player| player_names.include? player.name }
    else
      false
    end
  end

  def fuzzy_match_name(full_name, abbreviation)
    lowercase_name = full_name.downcase
    # The "Team" prefix in many team names can cause issues with this matching, so we need to handle it separately
    if lowercase_name.start_with? "team"
      lowercase_name.match(abbreviation.downcase.chars.join('.*')).to_s
    else
      lowercase_name.match("^" + abbreviation.downcase.chars.join('.*')).to_s
    end
  end

  def team_name_prefix(player_names)
    player_names.first.tap do |first_name|
      first_name.each_char.with_index do |char, idx|
        player_names.each do |player_name|
          return first_name[0, idx] if player_name[idx] != char
        end
      end
    end
  end

  def strip_team_name_prefix_from_player_name(team_name_prefix, player_name)
    player_name.dup.tap do |name|
      name.slice!(team_name_prefix) if team_name_prefix.present?
    end
  end
end
