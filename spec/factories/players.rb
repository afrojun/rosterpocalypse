FactoryGirl.define do
  sequence(:player_name) { |n| "Player#{n}" }

  factory :player do
    name { generate :player_name }
    role "role"
    country "Country"
    team
    value { rand 80..100 }
  end
end
