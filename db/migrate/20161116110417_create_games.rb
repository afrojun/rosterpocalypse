class CreateGames < ActiveRecord::Migration[5.0]
  def change
    create_table :games do |t|
      t.references :map,      null: false, foreign_key: true
      t.datetime :start_date, null: false
      t.integer :duration_s,  null: false
      t.string :game_hash,    null: false

      t.timestamps
    end

    add_index :games, :game_hash, unique: true
  end
end
