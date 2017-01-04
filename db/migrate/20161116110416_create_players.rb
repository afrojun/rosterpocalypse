class CreatePlayers < ActiveRecord::Migration[5.0]
  def change
    create_table :players do |t|
      t.string :name,     null: false, default: ""
      t.string :role
      t.references :team
      t.string :country
      t.integer :value,   null: false, default: 100
      t.string :slug,     null: false

      t.timestamps
    end

    add_index :players, :name, unique: true
    add_index :players, :slug, unique: true
  end
end
