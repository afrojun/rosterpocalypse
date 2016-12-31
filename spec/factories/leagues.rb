FactoryGirl.define do
  factory :public_league do
    name "My Public League"
    tournament
    type "PublicLeague"
  end

  factory :private_league do
    name "My Private League"
    tournament
    type "PrivateLeague"
  end
end
