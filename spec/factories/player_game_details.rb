FactoryGirl.define do
  factory :player_game_detail do
    player
    game
    hero
    team
    solo_kills { rand 0..10 }
    assists { rand 0..10 }
    deaths { rand 0..10 }
    time_spent_dead { rand 1..180 }
    team_colour { ["red", "blue"].sample }
    win { [true, false].sample }
  end
end
