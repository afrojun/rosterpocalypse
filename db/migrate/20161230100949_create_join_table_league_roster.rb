class CreateJoinTableLeagueRoster < ActiveRecord::Migration[5.0]
  def change
    create_join_table :leagues, :rosters do |t|
      t.index [:league_id, :roster_id]
      t.index [:roster_id, :league_id]
    end
  end
end
