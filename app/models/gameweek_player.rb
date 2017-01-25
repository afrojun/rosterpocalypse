class GameweekPlayer < ApplicationRecord
  belongs_to :gameweek
  belongs_to :player
  has_many :games, through: :gameweek
  has_many :game_details, -> { order "games.start_date DESC" }, through: :games

  serialize :points_breakdown, Hash

  BONUS_AWARD_PERCENTILE = 80
  MIN_GAMES_FOR_BONUS_AWARD = 30
  REPRESENTATIVE_GAME_NAME = "representative_game"

  def self.update_from_game game, gameweek
    game.game_details.each do |detail|
      gameweek_player = GameweekPlayer.find_or_create_by gameweek: gameweek, player: detail.player
      gameweek_player.refresh game, detail
    end
  end

  def remove_game game
    all_points_breakdowns = points_breakdown || {}
    all_points_breakdowns.delete(game.game_hash)
    update points_breakdown: all_points_breakdowns
    update_points
  end

  # Refresh all game points for this gameweek
  def update_all_games
    update points_breakdown: {}
    player_game_details.each do |detail|
      refresh detail.game, detail
    end
  end

  def player_game_details
    @player_game_details ||= game_details.where(player: player).includes(:team, :player, :game)
  end

  def team
    @team ||= player_game_details.first.team
  end

  def refresh game, detail
    all_points_breakdowns = points_breakdown || {}
    all_points_breakdowns[game.game_hash] = points_breakdown_hash(game, detail)
    update points_breakdown: all_points_breakdowns
    update_points
  end

  def representative_game_points
    @representative_game_points ||= points_breakdown[REPRESENTATIVE_GAME_NAME]
  end

  def game_points_breakdowns
    @game_points_breakdowns ||= points_breakdown.reject { |game_hash, _| game_hash == REPRESENTATIVE_GAME_NAME }
  end

  def points_breakdowns_by_game
    @points_breakdowns_by_game ||= Hash[
      game_points_breakdowns.map do |game_hash, breakdown|
        [Game.find(game_hash), breakdown]
      end.sort_by { |game, _| game.start_date }
    ]
  end

  private

  def update_points
    points_arrays = {
      solo_kills: [],
      assists: [],
      time_spent_dead: [],
      win: [],
      bonus: []
    }
    game_points_breakdowns.each do |_, game_points_breakdown|
      points_arrays[:solo_kills].push(game_points_breakdown[:solo_kills])
      points_arrays[:assists].push(game_points_breakdown[:assists])
      points_arrays[:win].push(game_points_breakdown[:win])
      points_arrays[:time_spent_dead].push(game_points_breakdown[:time_spent_dead])
      points_arrays[:bonus].concat(game_points_breakdown[:bonus])
    end

    representative_points = {}
    representative_points[:solo_kills] = points_arrays[:solo_kills].extend(DescriptiveStatistics).mean.round
    representative_points[:assists] = points_arrays[:assists].extend(DescriptiveStatistics).mean.round
    # Use the ceiling for :win only because we if a player wins at least one game we want to award a point
    representative_points[:win] = points_arrays[:win].extend(DescriptiveStatistics).mean.ceil
    representative_points[:time_spent_dead] = points_arrays[:time_spent_dead].extend(DescriptiveStatistics).mean.round
    representative_points[:bonus] = points_arrays[:bonus]
    representative_points[:total] = points_for_game(representative_points)

    all_points_breakdowns = points_breakdown
    all_points_breakdowns[REPRESENTATIVE_GAME_NAME] = representative_points

    update(
      points_breakdown: all_points_breakdowns,
      # overall points cannot be negative
      points: [representative_points[:total], 0].max
    )
  end

  def points_for_game game_points_breakdown
    game_points_breakdown[:solo_kills] +
      game_points_breakdown[:assists] +
      game_points_breakdown[:win] +
      game_points_breakdown[:time_spent_dead] +
      game_points_breakdown[:bonus].count
  end

  # Points breakdown:
  #
  # Category        |  Assasin/Flex |   Warrior  |  Support
  # ----------------|---------------|------------|------------
  # solo_kills      |       +3      |     +1     |     +1
  # assists         |       +1      |     +1     |     +1
  # time_spent_dead |   -(time/20)  | -(time/30) | -(time/30)
  # win             |       +5      |     +5     |     +5
  # bonus           |    variable   |  variable  |  variable
  #
  def points_breakdown_hash game, detail
    role_stat_modifiers = {
      assassin: { solo_kills: 3, assists: 1, time_spent_dead: 20.0, win: 5 },
      flex:     { solo_kills: 3, assists: 1, time_spent_dead: 20.0, win: 5 },
      warrior:  { solo_kills: 1, assists: 1, time_spent_dead: 30.0, win: 5 },
      support:  { solo_kills: 1, assists: 1, time_spent_dead: 30.0, win: 5 },
    }

    # Assume the player is an assassin if we cannot figure out the role
    role = detail.player.role.present? ? detail.player.role.downcase.to_sym : :assassin
    breakdown = {
      solo_kills: detail.solo_kills * role_stat_modifiers[role][:solo_kills],
      assists: detail.assists * role_stat_modifiers[role][:assists],
      time_spent_dead: -(detail.time_spent_dead.to_f/role_stat_modifiers[role][:time_spent_dead]).round,
      win: detail.win_int * role_stat_modifiers[role][:win],
      bonus: bonus_awards(game, detail)
    }
    breakdown[:total] = points_for_game(breakdown)
    breakdown
  end

  # Bonus categories:
  # +1 point for each
  #
  # Player:
  # All roles:
  #   :zero_deaths
  #   :win_faster_than_map_ave
  #
  # Assassin/Flex:
  #   :more_kills_than_ave_for_role
  #   :more_kills_than_ave_for_hero
  #
  # Warrior:
  #   :more_assists_than_ave_for_role
  #   :more_assists_than_ave_for_hero
  #
  # Support:
  #   :less_team_deaths_than_ave
  #
  def bonus_awards game, detail
    bonuses = [] +
              player_role_awards(detail) +
              hero_awards(detail) +
              team_awards(game, detail) +
              map_awards(game, detail)

    Rails.logger.info "Bonus Awards granted to #{detail.player.name}: #{bonuses.inspect}" if bonuses.any?
    bonuses
  end

  def player_role_awards detail
    role = detail.player.role
    if Player.players_in_role(role).size > MIN_GAMES_FOR_BONUS_AWARD
      stat = case role
             when "Support"
               "assists"
             when "Warrior"
               "assists"
             else
               "solo_kills"
             end

      threshold = Player.role_stat_percentile role, stat, BONUS_AWARD_PERCENTILE
      if threshold < detail.send(stat.to_sym)
        return ["#{BONUS_AWARD_PERCENTILE}th percentile in #{stat} for #{role} players"]
      end
    end
    []
  end

  def hero_awards detail
    hero = detail.hero
    if hero.game_details.size > MIN_GAMES_FOR_BONUS_AWARD
      stat = case hero.classification
             when "Support"
               "assists"
             when "Warrior"
               "assists"
             else
               "solo_kills"
             end

      threshold = detail.hero.stat_percentile stat, BONUS_AWARD_PERCENTILE
      if threshold < detail.send(stat.to_sym)
        return ["#{BONUS_AWARD_PERCENTILE}th percentile in #{stat} for #{hero.name}"]
      end
    end
    []
  end

  def team_awards game, detail
    if detail.player.role == "Support" && Game.all.size > MIN_GAMES_FOR_BONUS_AWARD
      team = detail.team
      stat = "deaths"
      Rails.logger.info "Team stats: #{game.team_stats.inspect}"
      team_deaths = game.team_stats[team.name][:deaths]
      # We want this to be low, so we take the inverse percentile
      inverse_percentile = 100 - BONUS_AWARD_PERCENTILE
      threshold = Game.team_stat_percentile stat, inverse_percentile
      if threshold > team_deaths
        return ["#{inverse_percentile}th percentile in team #{stat}"]
      end
    end
    []
  end

  def map_awards game, detail
    map  = game.map
    if map.games.size > MIN_GAMES_FOR_BONUS_AWARD
      # We want this to be low, so we take the inverse percentile
      inverse_percentile = 100 - BONUS_AWARD_PERCENTILE
      threshold = map.duration_percentile inverse_percentile
      if threshold > game.duration_s && detail.win
        return ["#{inverse_percentile}th percentile in duration for #{map.name}"]
      end
    end
    []
  end
end
