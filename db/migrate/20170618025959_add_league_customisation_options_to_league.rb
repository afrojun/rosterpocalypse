class AddLeagueCustomisationOptionsToLeague < ActiveRecord::Migration[5.0]
  def up
    add_column :leagues, :starting_budget,          :float,   null: false, default: 500.0
    add_column :leagues, :num_transfers,            :integer, null: false, default: 1
    add_column :leagues, :max_players_per_team,     :integer, null: false, default: 5
    add_column :leagues, :use_representative_game,  :boolean, null: false, default: false
    add_column :leagues, :role_stat_modifiers,      :text
    add_column :leagues, :required_player_roles,    :text

    role_stat_modifiers = {
      assassin: { solo_kills: 3, assists: 1, time_spent_dead: 20.0, win: 5 },
      flex:     { solo_kills: 3, assists: 1, time_spent_dead: 20.0, win: 5 },
      warrior:  { solo_kills: 1, assists: 1, time_spent_dead: 30.0, win: 5 },
      support:  { solo_kills: 1, assists: 1, time_spent_dead: 30.0, win: 5 },
    }
    required_player_roles = {
      assassin: 0,
      flex:     0,
      warrior:  1,
      support:  1,
    }
    League.all.each do |league|
      league.update role_stat_modifiers: role_stat_modifiers,
                    required_player_roles: required_player_roles
    end

    change_column_null :leagues, :role_stat_modifiers,   false
    change_column_null :leagues, :required_player_roles, false
  end

  def down
    remove_column :leagues, :starting_budget
    remove_column :leagues, :num_transfers
    remove_column :leagues, :max_players_per_team
    remove_column :leagues, :use_representative_game
    remove_column :leagues, :role_stat_modifiers
    remove_column :leagues, :required_player_roles
  end
end
