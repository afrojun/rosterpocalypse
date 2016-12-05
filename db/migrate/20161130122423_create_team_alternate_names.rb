class CreateTeamAlternateNames < ActiveRecord::Migration[5.0]
  def change
    create_table :team_alternate_names do |t|
      t.references :team, foreign_key: true
      t.string :alternate_name, null: false

      t.timestamps
    end

    add_index :team_alternate_names, :alternate_name, unique: true
  end
end
