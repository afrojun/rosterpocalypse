class AddValueAndTeamToGameweekPlayer < ActiveRecord::Migration[5.0]
  def up
    add_column :gameweek_players, :value,   :float
    add_column :gameweek_players, :team_id, :integer

    GameweekPlayer.reset_column_information

    say_with_time "Copying player values and team to the new columns" do
      GameweekPlayer.all.includes(:player).each do |gameweek_player|
        gameweek_player.update value: gameweek_player.player.value, team: gameweek_player.player.team
      end
    end
  end

  def down
    remove_column :gameweek_players, :value
    remove_column :gameweek_players, :team_id
  end
end
