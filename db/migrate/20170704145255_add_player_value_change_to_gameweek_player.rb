class AddPlayerValueChangeToGameweekPlayer < ActiveRecord::Migration[5.0]
  def change
    add_column :gameweek_players, :player_value_change, :float, null: false, default: 0.0
  end
end
