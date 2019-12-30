FactoryBot.define do
  factory :player_alternate_name do
    player
    alternate_name { 'MyString' }
  end
end
