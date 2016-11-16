class CreatePlayers < ActiveRecord::Migration[5.0]
  def change
    create_table :players do |t|
      t.string :name,     null: false, default: ""
      t.string :role
      t.references :team
      t.string :country
      t.string :region
      t.integer :cost,    null: false, default: 100

      t.timestamps
    end

    add_index :players, :name, unique: true
  end
end
