desc 'This is a one-off task to backfill the matches table.'

task backfill_matches: :environment do
  Game.includes(game_details: [:team]).where(match: nil).each do |game|
    Match.add_game game
  end
end
