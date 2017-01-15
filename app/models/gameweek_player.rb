class GameweekPlayer < ApplicationRecord
  belongs_to :gameweek
  belongs_to :player
  has_many :games, through: :gameweek
  has_many :game_details, -> { order "games.start_date DESC" }, through: :games

  serialize :points_breakdown, Hash

  BONUS_AWARD_PERCENTILE = 80
  MAX_BONUS_POINTS = 4
  MIN_GAMES_FOR_BONUS_AWARD = 30

  def self.update_from_game game, gameweek
    game.game_details.each do |detail|
      gameweek_player = GameweekPlayer.find_or_create_by gameweek: gameweek, player: detail.player
      gameweek_player.refresh game, detail
    end
  end

  # Refresh all game points for this gameweek
  def update_all_games
    update_attribute :points_breakdown, {}
    player_game_details.each do |detail|
      refresh detail.game, detail
    end
  end

  def player_game_details
    game_details.where(player: player)
  end

  def team
    player_game_details.first.team
  end

  def refresh game, detail
    all_points_breakdowns = points_breakdown || {}
    all_points_breakdowns[game.game_hash] = points_breakdown_hash(game, detail)
    update_attribute :points_breakdown, all_points_breakdowns
    update_points
  end

  def points_breakdowns_by_game
    Hash[
      points_breakdown.map do |game_hash, breakdown|
        [Game.find(game_hash), breakdown]
      end.sort_by { |game, _| game.start_date }
    ]
  end

  private

  def update_points
    total_points = points_breakdown.map do |_, game_points_breakdown|
                     points_for_game game_points_breakdown
                   end.sum
    # overall points cannot be negative
    update_attribute :points, [total_points, 0].max
  end

  def points_for_game game_points_breakdown
    game_points_breakdown[:solo_kills] +
      game_points_breakdown[:assists] +
      game_points_breakdown[:win] +
      game_points_breakdown[:time_spent_dead] +
      [game_points_breakdown[:bonus].count, MAX_BONUS_POINTS].min
  end

  # Points breakdown:
  #
  # Category        |  Assasin/Flex |   Warrior  |  Support
  # ----------------|---------------|------------|------------
  # solo_kills      |       +3      |     +1     |     +1
  # assists         |       +1      |     +1     |     +1
  # time_spent_dead |   -(time/20)  | -(time/30) | -(time/30)
  # win             |       +2      |     +2     |     +2
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
  # +1 point for each, max of +MAX_BONUS_POINTS
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
        return ["#{BONUS_AWARD_PERCENTILE}th_percentile_in_#{stat}_for_#{role.downcase}".to_sym]
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
        return ["#{BONUS_AWARD_PERCENTILE}th_percentile_in_#{stat}_for_#{hero.slug.underscore}".to_sym]
      end
    end
    []
  end

  def team_awards game, detail
    if detail.player.role == "Support" && Game.all.size > MIN_GAMES_FOR_BONUS_AWARD
      team = detail.team
      stat = "deaths"
      team_deaths = game.team_stats[team.name][:deaths]
      # We want this to be low, so we take the inverse percentile
      inverse_percentile = 100 - BONUS_AWARD_PERCENTILE
      threshold = Game.team_stat_percentile stat, inverse_percentile
      if threshold > team_deaths
        return ["#{inverse_percentile}th_percentile_in_team_#{stat}".to_sym]
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
        return ["#{inverse_percentile}th_percentile_in_duration_for_#{map.slug.underscore}".to_sym]
      end
    end
    []
  end
end
