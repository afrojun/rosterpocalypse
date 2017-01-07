FactoryGirl.define do
  sequence(:game_hash) { |n| "Hash#{n}" }

  factory :game do
    map
    gameweek
    start_date { Time.now.utc }
    duration_s { rand 300..1500 }
    game_hash { generate :game_hash }
  end

  trait :with_details do
    transient do
      number_of_details 10
    end

    after :create do |game, evaluator|
      FactoryGirl.create_list :game_details, evaluator.number_of_details, :game => game
    end
  end


end
