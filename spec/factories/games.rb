FactoryGirl.define do
  sequence(:game_hash) { |n| "Hash#{n}" }

  factory :game do
    map
    start_date { Time.now.utc }
    duration_s { rand 300..1500 }
    game_hash { generate :game_hash }
  end
end
