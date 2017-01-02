FactoryGirl.define do
  sequence(:roster_name) { |n| "Roster#{n}" }

  factory :roster do
    name { generate :roster_name }
    region { Tournament::REGIONS.sample }
    manager
    score 323
  end
end
