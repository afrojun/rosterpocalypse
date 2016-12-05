class CreatePlayerAlternateNames < ActiveRecord::Migration[5.0]
  def change
    create_table :player_alternate_names do |t|
      t.references :player, foreign_key: true
      t.string :alternate_name, null: false

      t.timestamps
    end

    add_index :player_alternate_names, :alternate_name, unique: true
  end
end
