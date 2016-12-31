json.extract! tournament, :id, :name, :region, :cycle_hours, :start_date, :end_date, :slug, :created_at, :updated_at
json.url tournament_url(tournament, format: :json)