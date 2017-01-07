class CreateGameweekPlayers < ActiveRecord::Migration[5.0]
  def change
    create_table :gameweek_players do |t|
      t.references :gameweek, foreign_key: true
      t.references :player,   foreign_key: true
      t.integer :points

      t.timestamps
    end
  end
end
