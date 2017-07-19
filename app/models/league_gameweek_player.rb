class LeagueGameweekPlayer < ApplicationRecord
  belongs_to :league
  belongs_to :gameweek_player
  has_one :gameweek, through: :gameweek_player
  has_one :player, through: :gameweek_player

  validates :league, presence: true
  validates :gameweek_player, presence: true
  validates :points, presence: true

  serialize :points_breakdown, Hash

  REPRESENTATIVE_GAME_NAME = "representative_game".freeze

  # FIXME: Move from GameweekPlayer
  def self.update_pick_rate_and_efficiency_for_gameweek(gameweek)
    gameweek_players = gameweek.gameweek_players.includes(:player, :gameweek_rosters)
    valid_gameweek_rosters = gameweek.gameweek_rosters.includes(transfers: %i[player_in player_out]).where("points IS NOT NULL")

    max_points = gameweek_players.order(points: :desc).first.try :points
    min_value = gameweek.players.order(value: :asc).first.try :value
    efficiency_factor = max_points && min_value ? max_points / min_value : 1
    Rails.logger.info "Player Efficiency factor = max_points/min_value = #{max_points}/#{min_value} = #{efficiency_factor}"

    gameweek_players.each do |gameweek_player|
      gameweek_player.update(
        pick_rate: ((gameweek_player.gameweek_rosters.size.to_f / valid_gameweek_rosters.size.to_f) * 100).round(2),
        efficiency: (((gameweek_player.points / gameweek_player.value) / efficiency_factor) * 100).round(2)
      )
    end
  end

  def remove_game(game)
    all_points_breakdowns = points_breakdown || {}
    all_points_breakdowns.delete(game.game_hash)
    update points_breakdown: all_points_breakdowns
    update_points
  end

  def add(game, detail)
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
    if league.use_representative_game
      # Create a representative game using the mean values scored across all games
      # in this gameweek
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
      # Use the ceiling for :win only, if a player wins at least one game we want to award a point
      representative_points[:win] = points_arrays[:win].extend(DescriptiveStatistics).mean.ceil
      representative_points[:time_spent_dead] = points_arrays[:time_spent_dead].extend(DescriptiveStatistics).mean.round
      representative_points[:bonus] = points_arrays[:bonus]
      representative_points[:total] = points_for_game(representative_points)

      all_points_breakdowns = points_breakdown
      all_points_breakdowns[REPRESENTATIVE_GAME_NAME] = representative_points

      update(
        points_breakdown: all_points_breakdowns,
        points: final_points(representative_points[:total])
      )
    else
      # Simply add up the total points of all games played this gameweek
      total_points = game_points_breakdowns.map do |_, game_points_breakdown|
        game_points_breakdown[:total]
      end.sum

      update(points: final_points(total_points))
    end
  end

  # Check with the League as to whether overall points can be negative
  def final_points(total)
    league.allow_negative_scores? ? total : [total, 0].max
  end

  def points_for_game(game_points_breakdown)
    game_points_breakdown[:solo_kills] +
      game_points_breakdown[:assists] +
      game_points_breakdown[:win] +
      game_points_breakdown[:time_spent_dead] +
      game_points_breakdown[:bonus].count
  end

  # Points breakdown:
  # 'k', 'a', 'w' and 'td' are pulled from league.role_stat_modifiers for a
  # given role.
  #
  # Category        |  Assasin/Flex |   Warrior  |  Support
  # ----------------|---------------|------------|------------
  # solo_kills      |       +k      |     +k     |     +k
  # assists         |       +a      |     +a     |     +a
  # time_spent_dead |   -(time/td)  | -(time/td) | -(time/td)
  # win             |       +w      |     +w     |     +w
  # bonus           |    variable   |  variable  |  variable
  #

  def points_breakdown_hash(game, detail)
    Rails.logger.info "Getting the points breakdown hash for the '#{league.name}' " \
                      "league using the role stat modifiers: #{league.role_stat_modifiers}."

    # Assume the player is an assassin if we cannot figure out the role
    role = gameweek_player.role.downcase
    Rails.logger.info "League Gameweek Player role: #{role}"
    breakdown = {
      solo_kills: detail.solo_kills * league.role_stat_modifiers[role]["solo_kills"].to_i,
      assists: detail.assists * league.role_stat_modifiers[role]["assists"].to_i,
      time_spent_dead: -(detail.time_spent_dead.to_f / league.role_stat_modifiers[role]["time_spent_dead"].to_f).round,
      win: detail.win_int * league.role_stat_modifiers[role]["win"].to_i,
      bonus: gameweek_player.points_breakdown[game.game_hash][:bonus]
    }
    breakdown[:total] = points_for_game(breakdown)
    breakdown
  end
end
