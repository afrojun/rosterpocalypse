# This class is a cache of the Player attributes during a particular gameweek.
# This allows us to refer to players that may have changed teams or roles later
# but know what those were for this gameweek

class GameweekPlayer < ApplicationRecord
  belongs_to :gameweek
  belongs_to :player
  belongs_to :team
  has_many :league_gameweek_players, dependent: :destroy
  has_many :leagues, through: :league_gameweek_players
  has_many :games, through: :gameweek
  has_many :game_details, -> { order 'games.start_date DESC' }, through: :games
  has_and_belongs_to_many :gameweek_rosters

  validates :gameweek, presence: true
  validates :player, presence: true
  validates :points, presence: true
  validates :role, presence: true
  validates :team, presence: true
  validates :value, presence: true
  validates :player_value_change, presence: true

  serialize :points_breakdown, Hash

  BONUS_AWARD_PERCENTILE = 90
  MIN_GAMES_FOR_BONUS_AWARD = 30

  def self.create_all_gameweek_players_for_gameweek(gameweek)
    regions = gameweek.tournament.region == 'Global' ? Team::REGIONS : gameweek.tournament.region
    Player.active_players.joins(:team).
      where(teams: { region: regions }).find_each do |player|
      gameweek_player = find_or_create_by(gameweek: gameweek, player: player) do |gwp|
        gwp.team  = player.team
        gwp.value = player.value
        gwp.role  = player.role
      end
      gameweek_player.find_or_create_league_gameweek_players
    end
  end

  def self.update_from_game(game, gameweek)
    game.game_details.each do |detail|
      gameweek_player = find_by(gameweek: gameweek, player: detail.player)
      if gameweek_player.present?
        gameweek_player.add game, detail
      else
        message = 'Unable to find gameweek player for ' \
                  "gameweek: #{gameweek.id}, player: #{detail.player.slug}"
        Rails.logger.error message
        raise message
      end
    end
  end

  # FIXME: This method needs to be updated to use LeagueGameweekPlayer instead
  def self.update_pick_rate_and_efficiency_for_gameweek(gameweek)
    league = gameweek.default_league

    gameweek_players = gameweek.gameweek_players.includes(:player, :gameweek_rosters)
    league_gameweek_players = league.league_gameweek_players.where(gameweek_player: gameweek_players).includes(:gameweek_player)
    valid_gameweek_rosters = gameweek.gameweek_rosters.includes(transfers: %i[player_in player_out]).where('points IS NOT NULL')

    max_points = league_gameweek_players.order(points: :desc).first.try :points
    min_value = gameweek_players.order(value: :asc).first.try :value
    efficiency_factor = max_points && min_value ? max_points / min_value : 1
    Rails.logger.info "Player Efficiency factor = max_points/min_value = #{max_points}/#{min_value} = #{efficiency_factor}"

    gameweek_players.each do |gameweek_player|
      Rails.logger.info "Player: #{gameweek_player.player.name}"
      league_gameweek_player = league_gameweek_players.find_by gameweek_player: gameweek_player
      gameweek_player.update(
        pick_rate: ((gameweek_player.gameweek_rosters.size.to_f / valid_gameweek_rosters.size.to_f) * 100).round(2),
        efficiency: (((league_gameweek_player.points / gameweek_player.value) / efficiency_factor) * 100).round(2)
      )
    end
  end

  def remove_game(game)
    all_points_breakdowns = points_breakdown || {}
    all_points_breakdowns.delete(game.game_hash)
    update points_breakdown: all_points_breakdowns

    league_gameweek_players.each { |lgwp| lgwp.remove_game game }
  end

  # Refresh all game points for this gameweek
  def refresh_all_games
    update points: 0, points_breakdown: {}

    league_gameweek_players.destroy_all
    find_or_create_league_gameweek_players

    player_game_details.each do |detail|
      add detail.game, detail
    end
  end

  def player_game_details
    @player_game_details ||= game_details.where(player: player).includes(:team)
  end

  def add(game, detail)
    # Bonus point awards are common across all leagues, so calculate them first
    # and store them in the GameweekPlayer's points_breakdown Hash
    bonus_points_breakdown = points_breakdown || {}
    bonus_points_breakdown[game.game_hash] = {
      bonus: bonus_awards(game, detail)
    }
    update points_breakdown: bonus_points_breakdown

    # Group the associated leagues by whether they share a common role_stat_modifiers
    # Hash, then group them again by whether they use a representative_game. This
    # greatly reduces the number of actual league_gameweek_players we need to process.
    # Once we finish processing the sample one, we simply copy the key attributes
    # (points_breakdown and points) to all the other league_gameweek_players.
    leagues.group_by(&:role_stat_modifiers).each do |_, same_mods_leagues|
      same_mods_leagues.group_by(&:use_representative_game).each do |_, rep_game_leagues|
        sample_league = rep_game_leagues.shift
        sample_league_gameweek_player = league_gameweek_players.find_by league: sample_league
        sample_league_gameweek_player.add game, detail

        league_gameweek_players.
          includes(:league).
          where(league: rep_game_leagues).
          update_all(points_breakdown: sample_league_gameweek_player.points_breakdown,
                     points: sample_league_gameweek_player.points)
      end
    end
  end

  def find_or_create_league_gameweek_players
    gameweek.leagues.each do |league|
      LeagueGameweekPlayer.find_or_create_by league: league, gameweek_player: self
    end
  end

  private

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
  def bonus_awards(game, detail)
    bonuses = [] +
              player_role_awards(detail) +
              hero_awards(detail) +
              team_awards(game, detail) +
              map_awards(game, detail)

    Rails.logger.info "Bonus Awards granted to #{detail.player.name}: #{bonuses.inspect}" if bonuses.any?
    bonuses
  end

  def player_role_awards(detail)
    if Player.players_in_role(role).size > MIN_GAMES_FOR_BONUS_AWARD
      stat = case role
             when 'Support'
               'assists'
             when 'Warrior'
               'assists'
             else
               'solo_kills'
             end

      threshold = Player.role_stat_percentile role, stat, BONUS_AWARD_PERCENTILE
      if threshold < detail.send(stat.to_sym)
        renamed_stat = stat == 'solo_kills' ? 'kills' : stat
        return ["#{BONUS_AWARD_PERCENTILE}th percentile in #{renamed_stat} for #{role} players"]
      end
    end
    []
  end

  def hero_awards(detail)
    hero = detail.hero
    if hero.game_details.size > MIN_GAMES_FOR_BONUS_AWARD
      stat = case hero.classification
             when 'Support'
               'assists'
             when 'Warrior'
               'assists'
             else
               'solo_kills'
             end

      threshold = detail.hero.stat_percentile stat, BONUS_AWARD_PERCENTILE
      if threshold < detail.send(stat.to_sym)
        renamed_stat = stat == 'solo_kills' ? 'kills' : stat
        return ["#{BONUS_AWARD_PERCENTILE}th percentile in #{renamed_stat} for #{hero.name}"]
      end
    end
    []
  end

  def team_awards(game, detail)
    if role == 'Support' && Game.all.size > MIN_GAMES_FOR_BONUS_AWARD
      team = detail.team
      stat = 'deaths'
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

  def map_awards(game, detail)
    map = game.map
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
