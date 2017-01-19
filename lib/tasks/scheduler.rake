desc "This task is called by the Heroku scheduler add-on"

task :update_player_values => :environment do
  puts "Updating player values..."
  Player.all.each { |player| player.update_value }
  puts "done."
end