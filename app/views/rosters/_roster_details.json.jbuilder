json.partial! "rosters/roster", roster: roster

json.league do
  json.partial! "leagues/league", league: roster.league
  json.roster_rank roster.league.roster_rank(roster)
  json.roster_count roster.league.rosters.size
end

json.tournament do
  json.partial! "tournaments/tournament", tournament: roster.tournament
end

json.current_gameweek do
  json.partial! "gameweeks/gameweek", gameweek: roster.current_gameweek
  json.extract! roster.current_gameweek_roster, :available_transfers, :remaining_transfers, :points_string
end

json.previous_gameweek do
  json.partial! "gameweeks/gameweek", gameweek: roster.previous_gameweek
  json.extract! roster.previous_gameweek_roster, :available_transfers, :remaining_transfers, :points_string
end

json.players roster.players.includes(:team) do |player|
  json.partial! "players/player", player: player
end

json.transfers roster.transfers.first(5) do |transfer|
  json.partial! "rosters/transfer", transfer: transfer
end

json.matches roster.current_gameweek.matches.includes(team_1: [:alternate_names], team_2: [:alternate_names]) do |match|
  json.partial! "matches/match", match: match
end