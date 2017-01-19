class CreateStages < ActiveRecord::Migration[5.0]
  def change
    create_table :stages do |t|
      t.string :name
      t.references :tournament, foreign_key: true

      t.timestamps
    end
  end
end
