json.extract! roster, :id, :name, :region, :manager_id, :score, :created_at, :updated_at
json.url roster_url(roster, format: :json)

json.league do
  json.partial! "leagues/league", league: roster.leagues.first
end

json.gameweek do
  json.partial! "tournaments/gameweek", gameweek: roster.current_gameweeks.first
  json.extract! roster.current_gameweek_rosters.first, :available_transfers, :remaining_transfers
end

json.players roster.players do |player|
  json.partial! "players/player", player: player
end
