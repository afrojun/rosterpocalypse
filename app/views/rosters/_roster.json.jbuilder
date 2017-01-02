json.extract! roster, :id, :name, :region, :manager_id, :score, :created_at, :updated_at
json.url roster_url(roster, format: :json)

json.players roster.players do |player|
  json.partial! "players/player", player: player
end