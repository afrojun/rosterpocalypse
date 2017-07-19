class CreateGameweekStatistics < ActiveRecord::Migration[5.0]
  def change
    create_table :gameweek_statistics do |t|
      t.references :gameweek, index: { unique: true }, foreign_key: true, null: false
      t.text :dream_team
      t.text :top_transfers_in
      t.text :top_transfers_out

      t.timestamps
    end
  end
end
