class CreateHeroes < ActiveRecord::Migration[5.0]
  def change
    create_table :heroes do |t|
      t.string :name,           null: false
      t.string :internal_name,  null: false
      t.string :classification
      t.string :slug,           null: false

      t.timestamps
    end

    add_index :heroes, :name, unique: true
    add_index :heroes, :internal_name, unique: true
    add_index :heroes, :slug, unique: true
  end
end
