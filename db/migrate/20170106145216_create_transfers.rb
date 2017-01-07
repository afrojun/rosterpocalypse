class CreateTransfers < ActiveRecord::Migration[5.0]
  def change
    create_table :transfers do |t|
      t.references :gameweek,           foreign_key: true
      t.references :roster,             foreign_key: true
      t.references :player,             foreign_key: true
      t.string :type,      null: false

      t.timestamps
    end
  end
end
