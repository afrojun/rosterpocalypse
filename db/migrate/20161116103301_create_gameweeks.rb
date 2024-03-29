class CreateGameweeks < ActiveRecord::Migration[5.0]
  def change
    create_table :gameweeks do |t|
      t.string :name,               null: false
      t.references :tournament,     foreign_key: true
      t.datetime :start_date,       null: false
      t.datetime :roster_lock_date
      t.datetime :end_date,         null: false

      t.timestamps
    end

    add_index :gameweeks, :start_date
    add_index :gameweeks, :roster_lock_date
    add_index :gameweeks, :end_date
  end
end
