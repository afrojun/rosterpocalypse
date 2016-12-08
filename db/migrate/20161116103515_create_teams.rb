class CreateTeams < ActiveRecord::Migration[5.0]
  def change
    create_table :teams do |t|
      t.string :name, null: false
      t.string :slug, null: false

      t.timestamps
    end

    add_index :teams, :name, unique: true
    add_index :teams, :slug, unique: true
  end
end
