FactoryGirl.define do
  factory :transfer do
    gameweek_roster
    association :player_in, factory: :player
    association :player_out, factory: :player
  end
end
