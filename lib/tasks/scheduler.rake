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

task :list_duplicate_players => :environment do
  puts "Listing possible duplicate players..."
  Player.all.each do |player|
    if player.name.size > 1
      players_with_similar_name = Player.where("name ILIKE '%#{player.name}%'").to_a
      if players_with_similar_name.size > 1
        puts "#{player.name} => #{players_with_similar_name.map(&:name)}"
      end
    end
  end
  puts "done."
end
