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

  def update_points
    update_attribute :points, gameweek_points
  end

  def parse_snapshot
    @parsed_snapshot ||= begin
      if roster_snapshot.present?
        Hash[
          roster_snapshot[:players].map do |player_slug, value|
            player = Player.find_including_alternate_names(player_slug).first
            [player, value]
          end
        ]
      else
        {}
      end
    end
  end

  def snapshot_players
    parse_snapshot.keys
  end

  def gameweek_players players = snapshot_players
    players.map do |player|
      GameweekPlayer.where(gameweek: gameweek, player: player).first
    end
  end

  def gameweek_points
    gameweek_players.compact.map(&:points).sum.round(2)
  end

  def gameweek_players_by_player players = snapshot_players
    Hash[players.zip gameweek_players(players)]
  end

  def points_string
    points.present? ? points.to_s : "-"
  end
end
