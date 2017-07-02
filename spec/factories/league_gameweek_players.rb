FactoryGirl.define do
  factory :league_gameweek_player do
    association :league, factory: :private_league
    gameweek_player
    points 15
  end
end
