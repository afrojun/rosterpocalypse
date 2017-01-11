class CreateGames < ActiveRecord::Migration[5.0]
  def change
    create_table :games do |t|
      t.references :map,      null: false, foreign_key: true
      t.references :gameweek,              foreign_key: true
      t.datetime :start_date, null: false
      t.integer :duration_s,  null: false
      t.string :game_hash,    null: false
      t.string :slug,         null: false

      t.timestamps
    end

    add_index :games, :game_hash, unique: true
    add_index :games, :slug, unique: true
    add_index :games, :start_date
  end
end
