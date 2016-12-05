json.extract! roster, :id, :name, :manager_id, :score, :created_at, :updated_at
json.url roster_url(roster, format: :json)