json.extract! league, :id, :name, :description, :created_at, :updated_at
json.url league_url(league)

json.tournament do
  json.partial! "tournaments/tournament", tournament: league.tournament
end
