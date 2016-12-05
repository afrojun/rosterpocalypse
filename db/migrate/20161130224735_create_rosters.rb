class CreateRosters < ActiveRecord::Migration[5.0]
  def change
    create_table :rosters do |t|
      t.string :name, null: false
      t.references :manager, foreign_key: true
      t.integer :score, null: false, default: 0

      t.timestamps
    end

    add_index :rosters, :name, unique: true
  end
end
