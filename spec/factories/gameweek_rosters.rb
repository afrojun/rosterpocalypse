FactoryGirl.define do
  factory :gameweek_roster do
    gameweek
    roster
    roster_snapshot { {"players" => ["player1", "player2", "player3", "player4", "player5"]} }
    points 1
  end
end
