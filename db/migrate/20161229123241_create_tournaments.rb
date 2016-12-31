class CreateTournaments < ActiveRecord::Migration[5.0]
  def change
    create_table :tournaments do |t|
      t.string :name,         null: false
      t.string :region,       null: false
      t.integer :cycle_hours, null: false
      t.datetime :start_date, null: false
      t.datetime :end_date
      t.string :slug,         null: false

      t.timestamps
    end

    add_index :tournaments, :name, unique: true
    add_index :tournaments, :slug, unique: true
  end
end
