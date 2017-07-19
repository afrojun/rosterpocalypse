json.extract! transfer, :gameweek_roster_id, :player_in_id, :player_out_id, :created_at, :updated_at

json.gameweek do
  json.partial! 'gameweeks/gameweek', gameweek: transfer.gameweek_roster.gameweek
end

json.player_in do
  json.partial! 'players/player', player: transfer.player_in
end

json.player_out do
  json.partial! 'players/player', player: transfer.player_out
end
