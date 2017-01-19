class CreateMatches < ActiveRecord::Migration[5.0]
  def change
    create_table :matches do |t|
      t.integer    :team_1_id,    null: false,              index: true,  foreign_key: true
      t.integer    :team_2_id,    null: false,              index: true,  foreign_key: true
      t.references :gameweek,     null: false,                            foreign_key: true
      t.references :stage,                                                foreign_key: true
      t.integer    :best_of,      null: false,  default: 1
      t.datetime   :start_date,   null: false,              index: true

      t.timestamps
    end
  end
end
