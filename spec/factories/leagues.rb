FactoryGirl.define do
  factory :public_league do
    name "My Public League"
    description "League description"
    manager
    tournament
    type "PublicLeague"
  end

  factory :private_league do
    name "My Private League"
    description "League description"
    manager
    tournament
    type "PrivateLeague"
  end
end
