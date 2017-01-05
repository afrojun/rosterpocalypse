desc "This task is called by the Heroku scheduler add-on"
task :update_player_values => :environment do
  puts "Updating player values..."
  Player.all.each { |player| player.update_value }
  puts "done."
end

task :infer_player_roles => :environment do
  puts "Inferring player roles..."
  Player.all.each { |player| player.infer_role }
  puts "done."
end
