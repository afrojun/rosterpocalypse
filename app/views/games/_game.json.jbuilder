json.extract! game, :id, :map, :start_date, :duration_s, :game_hash, :created_at, :updated_at
json.url game_url(game, format: :json)