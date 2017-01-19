json.partial! "rosters/roster", roster: roster

json.public_leagues roster.public_leagues do |league|
  json.partial! "leagues/league", league: league
  json.roster_rank league.roster_rank(roster)
  json.roster_count league.rosters.size
end

json.private_leagues roster.private_leagues do |league|
  json.partial! "leagues/league", league: league
  json.roster_rank league.roster_rank(roster)
  json.roster_count league.rosters.size
end

json.tournament do
  json.partial! "tournaments/tournament", tournament: roster.tournament
end

json.current_gameweek do
  json.partial! "tournaments/gameweek", gameweek: roster.current_gameweek
  json.extract! roster.current_gameweek_roster, :available_transfers, :remaining_transfers, :points_string
end

json.previous_gameweek do
  json.partial! "tournaments/gameweek", gameweek: roster.previous_gameweek
  json.extract! roster.previous_gameweek_roster, :available_transfers, :remaining_transfers, :points_string
end

json.players roster.players do |player|
  json.partial! "players/player", player: player
end

json.transfers roster.transfers.first(5) do |transfer|
  json.partial! "rosters/transfer", transfer: transfer
end

json.matches roster.current_gameweek.matches do |match|
  json.partial! "matches/match", match: match
end