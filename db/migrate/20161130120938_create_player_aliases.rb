class CreatePlayerAliases < ActiveRecord::Migration[5.0]
  def change
    create_table :player_aliases do |t|
      t.reference :player
      t.string :alias

      t.timestamps
    end
    add_index :player_aliases, :player
  end
end
