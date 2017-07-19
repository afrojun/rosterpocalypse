class AddPremiumToLeagues < ActiveRecord::Migration[5.0]
  def change
    add_column :leagues, :premium, :boolean, null: false, default: false
    add_index :leagues, :premium

    League.where(manager: Manager.paid).
      where("created_at > '2017-06-15'").
      each { |league| league.toggle! :premium }
  end
end
