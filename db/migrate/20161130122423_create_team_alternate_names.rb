class CreateTeamAlternateNames < ActiveRecord::Migration[5.0]
  def change
    create_table :team_alternate_names do |t|
      t.references :team
      t.string :alternate_name, null:false, unique: true

      t.timestamps
    end
  end
end
