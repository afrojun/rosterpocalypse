json.extract! roster, :id, :name, :tournament_id, :manager_id, :score, :created_at, :updated_at
json.region roster.region
json.free_transfer_mode roster.allow_free_transfers?
json.unlocked roster.unlocked?
json.url roster_url(roster)
