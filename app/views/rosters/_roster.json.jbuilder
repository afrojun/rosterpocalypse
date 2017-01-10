json.extract! roster, :id, :name, :region, :manager_id, :score, :created_at, :updated_at
json.free_transfer_mode roster.allow_free_transfers?
json.unlocked roster.unlocked?
json.url roster_url(roster, format: :json)

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
  json.partial! "tournaments/tournament", tournament: roster.leagues.first.tournament
end

json.current_gameweek do
  json.partial! "tournaments/gameweek", gameweek: roster.current_gameweeks.first
  json.extract! roster.current_gameweek_rosters.first, :available_transfers, :remaining_transfers, :points_string
end

json.previous_gameweek do
  json.partial! "tournaments/gameweek", gameweek: roster.previous_gameweeks.first
  json.extract! roster.previous_gameweek_rosters.first, :available_transfers, :remaining_transfers, :points_string
end

json.players roster.players do |player|
  json.partial! "players/player", player: player
end

json.transfers roster.transfers.first(5) do |transfer|
  json.partial! "rosters/transfer", transfer: transfer
end
