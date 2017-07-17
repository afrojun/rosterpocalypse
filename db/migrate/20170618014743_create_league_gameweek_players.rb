class CreateLeagueGameweekPlayers < ActiveRecord::Migration[5.0]
  def up
    create_table :league_gameweek_players do |t|
      t.references :league,          null: false,  foreign_key: true
      t.references :gameweek_player, null: false,  foreign_key: true
      t.text       :points_breakdown
      t.integer    :points,          null: false,  default: 0

      t.timestamps

      t.index [:league_id, :gameweek_player_id], name: 'idx_league_gameweek_players_on_league_id_and_gameweek_player_id'
      t.index [:gameweek_player_id, :league_id], name: 'idx_league_gameweek_players_on_gameweek_player_id_and_league_id'
    end

    League.all.each do |league|
      league.tournament.gameweeks.each do |gameweek|
        gameweek.gameweek_players.each do |gameweek_player|
          LeagueGameweekPlayer.create(
            league: league,
            gameweek_player: gameweek_player,
            points_breakdown: gameweek_player.points_breakdown,
            points: gameweek_player.points
          )
        end
      end
    end
  end

  def down
    drop_table :league_gameweek_players
  end
end
