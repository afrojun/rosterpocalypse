class GameweekRoster < ApplicationRecord
  belongs_to :gameweek
  belongs_to :roster
  has_many :transfers, dependent: :destroy

  serialize :roster_snapshot, Hash

  DEFAULT_TRANSFERS_PER_GAMEWEEK = 1

  def remaining_transfers
    remaining = available_transfers - transfers.size
    [remaining, 0].max
  end

  def create_snapshot
    if roster.players.size == Roster::MAX_PLAYERS
      players_hash = Hash[roster.players.map { |player| [player.slug, player.value] }]
      snapshot = {
        players: players_hash,
        snapshot_time: Time.now.utc
      }
      update_attribute :roster_snapshot, snapshot
    else
      Rails.logger.warn "Unable to create a snapshot of an incomplete roster."
    end
  end

  def points_string
    points.present? ? points.to_s : "-"
  end
end
