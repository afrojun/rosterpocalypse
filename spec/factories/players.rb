FactoryBot.define do
  sequence(:player_name) { |n| format('Player%03d', n) }

  factory :player do
    name { generate :player_name }
    role { 'role' }
    country { 'Country' }
    team
    value { 100 }
  end
end
