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

  def next(safe = true)
    nxt = GameweekRoster.find_by gameweek: gameweek.next, roster: roster
    safe ? (nxt.nil? ? self : nxt) : nxt
  end

  def previous(safe = true)
    prev = GameweekRoster.find_by gameweek: gameweek.previous, roster: roster
    safe ? (prev.nil? ? self : prev) : prev
  end

  def create_snapshot(players_to_snapshot = roster.players, force = false)
    if !force && roster_snapshot.present?
      Rails.logger.warn "Roster snapshot for '#{roster.name}' exists, not taking any action."
      return true
    end

    if players_to_snapshot.size == Roster::MAX_PLAYERS
      snapshot = {
        player_ids: players_to_snapshot.map(&:id),
        budget: roster.budget,
        snapshot_time: Time.now.utc
      }
      update roster_snapshot: snapshot
    else
      Rails.logger.warn "Unable to create a snapshot of an incomplete roster: '#{roster.name}'"
      false
    end
  end

  def add_gameweek_players
    if snapshot_player_ids.present?
      snapshot_gameweek_players = GameweekPlayer.where(gameweek: gameweek, player_id: snapshot_player_ids)

      if snapshot_gameweek_players.size != Roster::MAX_PLAYERS
        Rails.logger.warn "Unable to associate gameweek players for an incomplete roster: '#{roster.name}'"
        return false
      end

      total_value = snapshot_gameweek_players.map(&:value).sum
      if total_value > snapshot_budget
        Rails.logger.warn "Total value of the players in roster '#{roster.name}' " \
                          "(#{total_value}) exceeds the budget of #{snapshot_budget}." \
                          "Proceeding anyway..."
      end

      gameweek_players.clear
      gameweek_players << snapshot_gameweek_players
    else
      Rails.logger.warn "No snapshot present for '#{roster.name}', " \
                        "unable to associate gameweek players."
      false
    end
  end

  def update_points
    if gameweek_players.size == Roster::MAX_PLAYERS
      update points: gameweek_points
    else
      Rails.logger.warn "gameweek_players size for '#{roster.name}' is not #{Roster::MAX_PLAYERS}, unable to update points."
      false
    end
  end

  def snapshot_budget
    roster_snapshot[:budget]
  end

  def snapshot_player_ids
    roster_snapshot[:player_ids]
  end

  def gameweek_points
    league_gameweek_players.map(&:points).compact.sum
  end

  def league_gameweek_players
    LeagueGameweekPlayer.where(league: roster.league,
                               gameweek_player: gameweek_players)
  end

  def points_string
    points.present? ? points.to_s : "-"
  end
end
