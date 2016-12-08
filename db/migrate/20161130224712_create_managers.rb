class CreateManagers < ActiveRecord::Migration[5.0]
  def change
    create_table :managers do |t|
      t.references :user, foreign_key: true
      t.string :slug, null: false

      t.timestamps
    end

    add_index :managers, :slug, unique: true
  end
end
