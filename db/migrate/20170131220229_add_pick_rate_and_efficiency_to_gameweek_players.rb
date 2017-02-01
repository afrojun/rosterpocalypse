class AddPickRateAndEfficiencyToGameweekPlayers < ActiveRecord::Migration[5.0]
  def change
    add_column :gameweek_players, :pick_rate,   :float, default: 0.0, null: false
    add_column :gameweek_players, :efficiency,  :float, default: 0.0, null: false
  end
end
