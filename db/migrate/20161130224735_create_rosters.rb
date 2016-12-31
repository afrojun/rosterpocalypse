class CreateRosters < ActiveRecord::Migration[5.0]
  def change
    create_table :rosters do |t|
      t.string :name,         null: false
      t.references :manager,  null: false, foreign_key: true
      t.integer :score,       null: false, default: 0
      t.string :slug,         null: false

      t.timestamps
    end

    add_index :rosters, :name, unique: true
    add_index :rosters, :slug, unique: true
  end
end
