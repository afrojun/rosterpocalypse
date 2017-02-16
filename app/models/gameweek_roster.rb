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
    safe ? (n.nil? ? self : n) : n
  end

  def previous safe = true
    p = GameweekRoster.where(gameweek: gameweek.previous, roster: roster).first
    safe ? (p.nil? ? self : p) : p
  end

  def create_snapshot players = roster.players
    if players.size == Roster::MAX_PLAYERS
      players_hash = {}
      players.each do |player|
        players_hash[player.slug] = player.value
      end
      snapshot = {
        players: players_hash,
        snapshot_time: Time.now.utc
      }
      update roster_snapshot: snapshot
    else
      Rails.logger.warn "Unable to create a snapshot of an incomplete roster."
      false
    end
  end

  def update_points
    if snapshot_players.present?
      players = Player.where(slug: snapshot_players.keys)
      total_value = snapshot_players.values.sum

      if players.size != Roster::MAX_PLAYERS
        Rails.logger.warn "Unable to update points for an incomplete roster."
        return false
      end

      if total_value > Roster::MAX_TOTAL_VALUE
        Rails.logger.warn "Total value of the players in the roster (#{total_value}) exceeds the limit of #{Roster::MAX_TOTAL_VALUE}."
        return false
      end

      snapshot_gameweek_players = GameweekPlayer.where(gameweek: gameweek, player: players)
      gameweek_players << snapshot_gameweek_players
      update points: gameweek_points
    else
      Rails.logger.warn "No snapshot present, unable to update points."
      false
    end
  end

  def snapshot_time
    roster_snapshot[:snapshot_time]
  end

  def snapshot_players
    roster_snapshot[:players]
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
