class CreateTransfers < ActiveRecord::Migration[5.0]
  def change
    create_table :transfers do |t|
      t.references :gameweek_roster,  null: false,                foreign_key: true
      t.integer    :player_in_id,     null: false,  index: true,  foreign_key: true
      t.integer    :player_out_id,    null: false,  index: true,  foreign_key: true

      t.timestamps
    end
  end
end
