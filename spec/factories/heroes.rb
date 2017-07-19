FactoryGirl.define do
  sequence(:hero_name) { |n| "Hero#{n}" }

  factory :hero do
    name { generate :hero_name }
    internal_name { name }
    classification { %w[Warrior Support Assassin Specialist].sample }
  end
end
