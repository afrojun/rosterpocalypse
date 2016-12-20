class CreateGameDetails < ActiveRecord::Migration[5.0]
  def change
    create_table :game_details do |t|
      t.references :game,                             null: false, foreign_key: true
      t.references :player,                           null: false, foreign_key: true
      t.references :hero,                             null: false, foreign_key: true
      t.references :team,                             null: false, foreign_key: true
      t.integer :solo_kills,        default: 0,       null: false
      t.integer :assists,           default: 0,       null: false
      t.integer :deaths,            default: 0,       null: false
      t.integer :time_spent_dead,   default: 0,       null: false
      t.string  :team_colour,                         null: false
      t.boolean :win,               default: false

      t.timestamps
    end
  end
end
