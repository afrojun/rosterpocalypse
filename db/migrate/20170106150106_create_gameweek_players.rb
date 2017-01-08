class CreateGameweekPlayers < ActiveRecord::Migration[5.0]
  def change
    create_table :gameweek_players do |t|
      t.references :gameweek,   null: false,            foreign_key: true
      t.references :player,     null: false,            foreign_key: true
      t.text :points_breakdown
      t.integer :points,        null: false, default: 0

      t.timestamps
    end
  end
end
