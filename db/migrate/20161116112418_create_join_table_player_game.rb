class CreateJoinTablePlayerGame < ActiveRecord::Migration[5.0]
  def change
    create_join_table :players, :games, table_name: :player_game_details do |t|
      t.index [:player_id, :game_id]
      t.index [:game_id, :player_id]
      t.references :hero
      t.integer :solo_kills
      t.integer :assists
      t.integer :deaths
      t.integer :time_spent_dead
      t.boolean :win,               default: false
    end
  end
end
