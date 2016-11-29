class CreateJoinTablePlayerGame < ActiveRecord::Migration[5.0]
  def change
    create_join_table :players, :games, table_name: :player_game_details do |t|
      t.index [:player_id, :game_id]
      t.index [:game_id, :player_id]
      t.references :hero,                             null: false
      t.integer :solo_kills,        default: 0,       null: false
      t.integer :assists,           default: 0,       null: false
      t.integer :deaths,            default: 0,       null: false
      t.integer :time_spent_dead,   default: 0,       null: false
      t.string  :team_colour,                         null: false
      t.boolean :win,               default: false
    end
  end
end
