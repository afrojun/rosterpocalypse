json.extract! player, :id, :name, :role, :country, :region, :cost, :created_at, :updated_at
json.url player_url(player, format: :json)