FactoryGirl.define do
  sequence(:team_name) { |n| "Team#{n}" }

  factory :team do
    name { generate :team_name }
  end
end
