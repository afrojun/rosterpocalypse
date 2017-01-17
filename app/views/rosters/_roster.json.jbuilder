json.extract! roster, :id, :name, :tournament_id, :manager_id, :score, :created_at, :updated_at
json.region roster.region
json.free_transfer_mode roster.allow_free_transfers?
json.unlocked roster.unlocked?
json.full roster.full?
json.allow_updates roster.allow_updates?
json.next_key_date roster.next_key_date
json.url roster_url(roster)
