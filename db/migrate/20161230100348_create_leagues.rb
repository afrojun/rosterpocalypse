class CreateLeagues < ActiveRecord::Migration[5.0]
  def change
    create_table :leagues do |t|
      t.string :name,           null: false
      t.text :description
      t.references :manager,    null: false, foreign_key: true
      t.references :tournament, null: false, foreign_key: true
      t.string :type,           null: false
      t.string :slug,           null: false

      t.timestamps
    end

    add_index :leagues, :name, unique: true
    add_index :leagues, :slug, unique: true
    add_index :leagues, :type
  end
end
