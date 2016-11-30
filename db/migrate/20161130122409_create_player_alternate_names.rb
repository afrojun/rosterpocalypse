class CreatePlayerAlternateNames < ActiveRecord::Migration[5.0]
  def change
    create_table :player_alternate_names do |t|
      t.references :player
      t.string :alternate_name, null:false, unique: true

      t.timestamps
    end
  end
end
