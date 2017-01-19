json.extract! team, :id, :name, :region, :active, :created_at, :updated_at
json.short_name team.short_name
json.logo image_path(team_logo_filename(team))
json.url team_url(team, format: :json)