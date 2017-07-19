# This is a one-off task.
#
# When the league rule modifiers (required_player_roles and role_stat_modifiers)
# were created, they were set to defaults using symbols as keys and numeric
# values. However, the form we use to input the data from users transforms all
# the keys and values to strings. To ensure consistency, we need to go back and
# update all the defaults to also use only strings.

desc "Convert League required_player_roles and role_stat_modifiers keys and values to Strings"

task league_rules_to_string: :environment do
  puts "Updating leagues..."
  League.all.each do |league|
    if league.required_player_roles.keys.first.is_a? Symbol
      sym_required_player_roles = league.required_player_roles
      sym_role_stat_modifiers = league.role_stat_modifiers

      str_required_player_roles = Hash[
        sym_required_player_roles.map { |role, num| [role.to_s, num.to_s] }
      ]

      str_role_stat_modifiers = Hash[
        sym_role_stat_modifiers.map do |role, stat_modifiers|
          [
            role.to_s,
            Hash[stat_modifiers.map { |stat, mod| [stat.to_s, mod.to_s] }]
          ]
        end
      ]

      league.update required_player_roles: str_required_player_roles,
                    role_stat_modifiers: str_role_stat_modifiers
      print "."
    end
  end
  puts "done."
end
