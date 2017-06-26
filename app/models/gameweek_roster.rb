class GameweekRoster < ApplicationRecord
  belongs_to :gameweek
  belongs_to :roster
  has_many :transfers, dependent: :destroy
  has_and_belongs_to_many :gameweek_players
  has_many :players, through: :gameweek_players

  serialize :roster_snapshot, Hash

  def remaining_transfers
    remaining = available_transfers - transfers.size
    [remaining, 0].max
  end

  def next safe = true
    nxt = GameweekRoster.where(gameweek: gameweek.next, roster: roster).first
    safe ? (nxt.nil? ? self : nxt) : nxt
  end

  def previous safe = true
    prev = GameweekRoster.where(gameweek: gameweek.previous, roster: roster).first
    safe ? (prev.nil? ? self : prev) : prev
  end

  def create_snapshot players_to_snapshot = roster.players
    if roster_snapshot.present?
      Rails.logger.warn "Roster snapshot for '#{roster.name}' exists, not taking any action."
      return true
    end

    if players_to_snapshot.size == Roster::MAX_PLAYERS
      players_hash = {}
      players_to_snapshot.each do |player|
        players_hash[player.id] = player.value
      end
      snapshot = {
        players: players_hash,
        budget: roster.budget,
        snapshot_time: Time.now.utc
      }
      update roster_snapshot: snapshot
    else
      Rails.logger.warn "Unable to create a snapshot of an incomplete roster: '#{roster.name}'"
      false
    end
  end

  def update_points
    if snapshot_players_hash.present?
      snapshot_players = Player.where(id: snapshot_players_hash.keys)
      if snapshot_players.size != Roster::MAX_PLAYERS
        Rails.logger.warn "Unable to update points for an incomplete roster: '#{roster.name}'"
        return false
      end

      total_value = snapshot_players_hash.values.sum
      if total_value > roster_snapshot[:budget]
        Rails.logger.warn "Total value of the players in roster '#{roster.name}' (#{total_value}) exceeds the budget of #{roster_snapshot[:budget]}."
        return false
      end

      gameweek_players.clear
      gameweek_players << GameweekPlayer.where(gameweek: gameweek, player: snapshot_players)

      update points: gameweek_points
    else
      Rails.logger.warn "No snapshot present for '#{roster.name}', unable to update points."
      false
    end
  end

  def snapshot_time
    roster_snapshot[:snapshot_time]
  end

  def snapshot_players_hash
    roster_snapshot[:players]
  end

  def player_value player
    gameweek_players.where(player: player).first.try :value
  end

  def gameweek_points
    @gameweek_points ||= LeagueGameweekPlayer.
                           where(league: roster.league,
                                 gameweek_player: gameweek_players).
                           map(&:points).compact.sum
  end

  def gameweek_players_by_player
    Hash[players.zip gameweek_players.includes(:player, :team)]
  end

  def points_string
    points.present? ? points.to_s : "-"
  end
end
