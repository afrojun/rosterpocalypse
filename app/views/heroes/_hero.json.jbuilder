json.extract! hero, :id, :name, :internal_name, :classification, :created_at, :updated_at
json.url hero_url(hero, format: :json)