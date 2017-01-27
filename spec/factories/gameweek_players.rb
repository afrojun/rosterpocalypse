FactoryGirl.define do
  factory :gameweek_player do
    gameweek
    player
    team
    points 15
    value 100
  end
end
