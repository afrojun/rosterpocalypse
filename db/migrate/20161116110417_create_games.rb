class CreateGames < ActiveRecord::Migration[5.0]
  def change
    create_table :games do |t|
      t.string :map
      t.datetime :start_date
      t.integer :duration_s
      t.string :game_hash

      t.timestamps
    end

    add_index :games, :game_hash, unique: true
  end
end
