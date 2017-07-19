json.extract! match, :id, :team_1_id, :team_2_id, :gameweek_id, :best_of, :start_date, :created_at, :updated_at
json.description match.short_description
json.team_1 do
  json.partial! "teams/team", team: match.team_1
end
json.team_2 do
  json.partial! "teams/team", team: match.team_2
end
json.url match_url(match)
