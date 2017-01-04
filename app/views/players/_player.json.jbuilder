json.extract! player, :id, :name, :role, :country, :value
json.url player_url(player)

json.team do
  json.name player.team.name
end