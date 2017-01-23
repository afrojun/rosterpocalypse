desc "This task is called by the Heroku scheduler add-on"

task :update_player_values => :environment do
  puts "Updating player values..."
  Player.all.each { |player| player.update_value }
  puts "Done."
end

task :snapshot_gameweek_rosters => :environment do
  puts "Snapshotting all valid Rosters for this Gameweek"
  rosters_to_snapshot = Roster.all.includes(:players, tournament: [:gameweeks]).select do |roster|
    roster.full? &&
      roster.created_at < roster.current_gameweek.roster_lock_date &&
      roster.updated_at < roster.current_gameweek.roster_lock_date
  end

  puts "Snapshotting #{rosters_to_snapshot.size} Rosters..."
  rosters_to_snapshot.each do |roster|
    gwr = roster.current_gameweek_roster
    gwr.create_snapshot
  end

  puts "Done."
end

task :update_roster_scores => :environment do
  puts "Updating Roster scores"
  Roster.all.each do |roster|
    gwr = roster.current_gameweek_roster
    next unless gwr.roster_snapshot.present?

    gwr.update_points
    roster.update_score
  end
  puts "Done."
end