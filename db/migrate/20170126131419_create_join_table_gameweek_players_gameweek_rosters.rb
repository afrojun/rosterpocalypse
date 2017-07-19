class CreateJoinTableGameweekPlayersGameweekRosters < ActiveRecord::Migration[5.0]
  def up
    create_join_table :gameweek_rosters, :gameweek_players do |t|
      t.index [:gameweek_roster_id, :gameweek_player_id], name: 'index_gameweek_players_rosters_on_gw_roster_id_and_gw_player_id'
      t.index [:gameweek_player_id, :gameweek_roster_id], name: 'index_gameweek_players_rosters_on_gw_player_id_and_gw_roster_id'
    end

    GameweekPlayer.reset_column_information
    GameweekRoster.reset_column_information

    say_with_time 'Populating the join table' do
      GameweekRoster.all.includes(:gameweek).each do |gameweek_roster|
        if gameweek_roster.roster_snapshot[:players].present?
          gameweek_roster.roster_snapshot[:players].each do |player_slug, _|
            gameweek_player = GameweekPlayer.where(gameweek: gameweek_roster.gameweek, player: Player.find(player_slug)).first
            if gameweek_player.present? && !gameweek_roster.gameweek_players.include?(gameweek_player)
              gameweek_roster.gameweek_players << gameweek_player
            end
          end
        end
      end
    end
  end

  def down
    drop_join_table :gameweek_rosters, :gameweek_players
  end
end
