class AddMatchToGame < ActiveRecord::Migration[5.0]
  def change
    add_reference :games, :match, foreign_key: true
  end
end
