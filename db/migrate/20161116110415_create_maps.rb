class CreateMaps < ActiveRecord::Migration[5.0]
  def change
    create_table :maps do |t|
      t.string :name, null: false
      t.string :slug, null: false

      t.timestamps
    end

    add_index :maps, :name, unique: true
    add_index :maps, :slug, unique: true
  end
end
