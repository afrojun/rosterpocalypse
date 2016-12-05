FactoryGirl.define do
  sequence(:roster_name) { |n| "Roster#{n}" }

  factory :roster do

    name { generate :roster_name }
    manager
    score 323
  end
end
