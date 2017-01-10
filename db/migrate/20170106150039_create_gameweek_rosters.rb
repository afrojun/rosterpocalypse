class CreateGameweekRosters < ActiveRecord::Migration[5.0]
  def change
    create_table :gameweek_rosters do |t|
      t.references :gameweek,         null: false,           foreign_key: true
      t.references :roster,           null: false,           foreign_key: true
      t.integer :available_transfers, null: false, default: 1
      t.text :roster_snapshot
      t.integer :points

      t.timestamps

      t.index [:gameweek_id, :roster_id]
      t.index [:roster_id, :gameweek_id]
    end
  end
end
