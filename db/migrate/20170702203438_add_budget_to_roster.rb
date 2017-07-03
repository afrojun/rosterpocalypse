class AddBudgetToRoster < ActiveRecord::Migration[5.0]
  def up
    add_column :rosters, :budget, :float, null: false, default: 500.0

    Roster.active_rosters.includes(:leagues).each do |roster|
      roster.update(budget: roster.league.starting_budget) if roster.league.present?
    end
  end

  def down
    remove_column :rosters, :budget
  end
end
