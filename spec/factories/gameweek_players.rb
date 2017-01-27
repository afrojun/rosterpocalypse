FactoryGirl.define do
  factory :gameweek_player do
    gameweek
    player
    points 15
    team
    value 100
  end
end
