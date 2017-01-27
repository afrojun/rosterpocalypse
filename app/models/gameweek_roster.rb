class GameweekRoster < ApplicationRecord
  belongs_to :gameweek
  belongs_to :roster
  has_many :transfers, dependent: :destroy
  has_and_belongs_to_many :gameweek_players
  has_many :players, through: :gameweek_players

  serialize :roster_snapshot, Hash

  DEFAULT_TRANSFERS_PER_GAMEWEEK = 1

  def remaining_transfers
    remaining = available_transfers - transfers.size
    [remaining, 0].max
  end

  def next safe = true
    n = GameweekRoster.where(gameweek: gameweek.next, roster: roster).first
    safe ? self : n
  end

  def previous safe = true
    p = GameweekRoster.where(gameweek: gameweek.previous, roster: roster).first
    safe ? self : p
  end

  def create_snapshot
    if roster.players.size == Roster::MAX_PLAYERS
      players_hash = {}
      roster.players.each do |player|
        players_hash[player.slug] = player.value
        gameweek_players << GameweekPlayer.where(gameweek: gameweek, player: player).first
      end
      snapshot = {
        players: players_hash,
        snapshot_time: Time.now.utc
      }
      update roster_snapshot: snapshot
    else
      Rails.logger.warn "Unable to create a snapshot of an incomplete roster."
    end
  end

  def update_points
    update points: gameweek_points
  end

  def snapshot_time
    roster_snapshot[:snapshot_time]
  end

  def player_value player
    gameweek_players.where(player: player).first.try :value
  end

  def gameweek_points
    @gameweek_points ||= gameweek_players.map(&:points).compact.sum
  end

  def gameweek_players_by_player
    Hash[players.zip gameweek_players.includes(:player, :team)]
  end

  def points_string
    points.present? ? points.to_s : "-"
  end
end
