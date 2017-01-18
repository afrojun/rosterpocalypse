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

task :populate_matches => :environment do
  match_score_sum_to_best_of = {
    [0, 0] => 1,
    [0, 1] => 1,

    [1, 1] => 3,
    [0, 2] => 3,
    [1, 2] => 3,

    [2, 2] => 5,
    [0, 3] => 5,
    [1, 3] => 5,
    [2, 3] => 5,

    [3, 3] => 7,
    [0, 4] => 7,
    [1, 4] => 7,
    [2, 4] => 7,
    [3, 4] => 7,

    [4, 4] => 9,
    [0, 5] => 9,
    [1, 5] => 9,
    [2, 5] => 9,
    [3, 5] => 9,
    [4, 5] => 9
  }

  Game.includes(game_details: [:team]).where(match: nil).each do |game|
    game_team_ids = game.teams.map(&:id)
    team_matches = Match.where("team_1_id in (?) AND team_2_id in (?)", game_team_ids, game_team_ids)
    team_date_matches = team_matches.to_a.select do |match|
                          ((match.games.last.start_date - game.start_date).abs < 14400)
                        end

    if team_date_matches.size == 0
      puts "Creating new Match..."
      match = Match.new(
        team_1: game.teams.first,
        team_2: game.teams.last,
        gameweek: game.gameweek,
        start_date: game.start_date,
        best_of: 1
      )
      match.save
      game.update_attribute(:match, match)

    elsif team_date_matches.size == 1
      puts "Updating existing Match..."
      match = team_date_matches.first
      game.update_attribute(:match, match)
      match.reload
      score = match.score.sort
      puts "score: #{score}"

      match.update_attributes(
        start_date: ((match.start_date < game.start_date) ? match.start_date : game.start_date),
        best_of: match_score_sum_to_best_of[score]
      )

    elsif team_date_matches.size > 1
      puts "ERROR: more than 1 possible match found! Unable to add game '#{game.game_hash}' to a match."
    end
  end
end