desc "2017-06-17: This is a one-off task to clear out Season 1 Phase 1 Roster " +
                 "and League data from all associated tables."

task :clear_s1p1_data => :environment do
  Roster.destroy_all
  League.destroy_all
  Transfer.destroy_all
  GameweekRoster.destroy_all
end