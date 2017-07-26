class AddMpPropertiesToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :mp_properties, :text
  end
end
