class AddRoleToGameweekPlayer < ActiveRecord::Migration[5.0]
  def change
    add_column :gameweek_players, :role, :string, null: false, default: ""

    GameweekPlayer.all.each do |gameweek_player|
      gameweek_player.update role: gameweek_player.player.role
    end
  end
end
