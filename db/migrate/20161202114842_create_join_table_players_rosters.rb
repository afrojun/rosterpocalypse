class CreateJoinTablePlayersRosters < ActiveRecord::Migration[5.0]
  def change
    create_join_table :rosters, :players do |t|
      t.index [:roster_id, :player_id]
      t.index [:player_id, :roster_id]
    end
  end
end
