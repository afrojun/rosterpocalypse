json.extract! league, :id, :name, :description, :created_at, :updated_at,
                      :starting_budget, :num_transfers, :max_players_per_team,
                      :use_representative_game, :role_stat_modifiers, :required_player_roles
json.url league_url(league)
