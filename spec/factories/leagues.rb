FactoryGirl.define do
  sequence(:private_league_name) { |n| "PrivateLeague#{n}" }
  sequence(:public_league_name) { |n| "PublicLeague#{n}" }

  factory :public_league do
    name { generate :private_league_name }
    description 'League description'
    manager
    tournament
    type 'PublicLeague'
    role_stat_modifiers League::DEFAULT_ROLE_STAT_MODIFIERS
    required_player_roles League::DEFAULT_REQUIRED_PLAYER_ROLES
  end

  factory :private_league do
    name { generate :public_league_name }
    description 'League description'
    manager
    tournament
    type 'PrivateLeague'
    role_stat_modifiers League::DEFAULT_ROLE_STAT_MODIFIERS
    required_player_roles League::DEFAULT_REQUIRED_PLAYER_ROLES
  end
end
