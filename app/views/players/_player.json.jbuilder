json.extract! player, :id, :name, :role, :country, :region, :cost
json.url player_url(player)

json.team do
  json.name player.team.name
end