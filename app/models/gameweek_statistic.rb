class GameweekStatistic < ApplicationRecord
  belongs_to :gameweek

  serialize :dream_team, Hash
  serialize :top_transfers_in, Array
  serialize :top_transfers_out, Array

  def self.update_all_stats_for_gameweek(gameweek)
    gameweek_stat = GameweekStatistic.find_or_create_by gameweek: gameweek
    gameweek_stat.create_dream_team
    gameweek_stat.update_top_transfers
  end

  def create_dream_team
    gameweek_players = gameweek.gameweek_players.includes(:player).order(efficiency: :desc)

    return unless gameweek_players.any?

    dream_team_gameweek_players = Set.new
    dream_team_gameweek_players << gameweek_players.detect { |gameweek_player| gameweek_player.player.role == 'Warrior' }
    dream_team_gameweek_players << gameweek_players.detect { |gameweek_player| gameweek_player.player.role == 'Support' }
    index = 0
    while gameweek_players[index].present? && dream_team_gameweek_players.size < Roster::MAX_PLAYERS
      dream_team_gameweek_players << gameweek_players[index]
      index += 1
    end

    update!(
      dream_team: {
        gameweek_player_ids: dream_team_gameweek_players.map(&:id),
        value: dream_team_gameweek_players.map(&:value).sum.round(2),
        points: dream_team_gameweek_players.map do |gameweek_player|
                  LeagueGameweekPlayer.find_by(league: gameweek.default_league, gameweek_player: gameweek_player).try(:points)
                end.compact.sum
      }
    )
  end

  def update_top_transfers
    transfers_in = Transfer.gameweek_transfers_in(gameweek).sort { |(_, a), (_, b)| a <=> b }.last(5).reverse
    transfers_out = Transfer.gameweek_transfers_out(gameweek).sort { |(_, a), (_, b)| a <=> b }.last(5).reverse

    update!(
      top_transfers_in: transfers_in,
      top_transfers_out: transfers_out
    )
  end

  def dream_team_gameweek_players
    @dream_team_gameweek_players ||= GameweekPlayer.where(id: dream_team[:gameweek_player_ids]).includes(:team, player: [:team])
  end

  def dream_team_value
    dream_team[:value]
  end

  def dream_team_points
    dream_team[:points]
  end
end
