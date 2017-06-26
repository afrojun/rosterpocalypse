require "thor/rails"

class SnapshotGameweekRosters < Thor
  include Thor::Rails

  desc "update", "Update roster snapshots for the current gameweek"

  method_option :force, default: false, aliases: '-f', type: :boolean, desc: 'Force snapshot updates'

  def update
    puts "Snapshotting all valid Rosters for this Gameweek"
    rosters_to_snapshot = Roster.
          where(tournament: Tournament.active_tournaments).
          includes(:players, tournament: [:gameweeks]).select do |roster|
      roster.full? &&
      roster.created_at < roster.current_gameweek.roster_lock_date &&
      roster.updated_at < roster.current_gameweek.roster_lock_date
    end

    puts "Snapshotting #{rosters_to_snapshot.size} Rosters..."
    puts "Forcing updates even for rosters that are already snapshotted" if options.force?
    rosters_to_snapshot.each do |roster|
      gwr = roster.current_gameweek_roster
      gwr.create_snapshot roster.players, options.force
    end

    puts "Done."
  end
end