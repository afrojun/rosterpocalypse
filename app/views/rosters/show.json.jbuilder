json.partial! 'rosters/roster', roster: @roster

json.current_gameweek do
  json.partial! 'rosters/gameweek_roster', gameweek_roster: @gameweek_roster
end

json.next_gameweek do
  json.partial! 'rosters/gameweek_roster', gameweek_roster: @gameweek_roster.next
end

json.previous_gameweek do
  json.partial! 'rosters/gameweek_roster', gameweek_roster: @gameweek_roster.previous
end

json.player_details @gameweek_roster.gameweek_players.compact do |gameweek_player|
  json.partial! 'players/gameweek_player', gameweek_player: gameweek_player
end
