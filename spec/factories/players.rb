FactoryGirl.define do
  sequence(:player_name) { |n| "Player#{n}" }

  factory :player do
    name { generate :player_name }
    role "role"
    country "Country"
    region { ["NA, EU, KR, CN"].sample }
    team
    cost { rand 50..150 }
  end
end
