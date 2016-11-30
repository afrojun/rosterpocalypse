class CreateHeroes < ActiveRecord::Migration[5.0]
  def change
    create_table :heroes do |t|
      t.string :name,           null: false, unique: true
      t.string :internal_name,  null: false, unique: true
      t.string :classification

      t.timestamps
    end
  end
end
