FactoryGirl.define do
  sequence(:map_name) { |n| "Map#{n}" }

  factory :map do
    name { generate :map_name }
  end
end
