FactoryGirl.define do
  sequence(:private_league_name) { |n| "PrivateLeague#{n}" }
  sequence(:public_league_name) { |n| "PublicLeague#{n}" }

  factory :public_league do
    name { generate :private_league_name }
    description "League description"
    manager
    tournament
    type "PublicLeague"
  end

  factory :private_league do
    name { generate :public_league_name }
    description "League description"
    manager
    tournament
    type "PrivateLeague"
  end
end
