require "thor/rails"

class GameweekRosterActions < Thor
  include Thor::Rails

  desc "snapshot", "Create roster snapshots for the current gameweek"
  method_option :force, default: false, aliases: '-f', type: :boolean, desc: 'Force snapshot updates'

  def snapshot
    puts "Snapshotting all valid Rosters for this Gameweek"
    rosters_to_snapshot = Roster.
          where(tournament: Tournament.active_tournaments).
          includes(:players, tournament: [:gameweeks]).select do |roster|
      roster.full? &&
      roster.created_at < roster.current_gameweek.roster_lock_date &&
      roster.updated_at < roster.current_gameweek.roster_lock_date
    end

    puts "Snapshotting #{rosters_to_snapshot.size} Rosters..."
    puts "Forcing updates even for rosters that are already snapshotted" if options.force?
    rosters_to_snapshot.each do |roster|
      gwr = roster.current_gameweek_roster
      gwr.create_snapshot roster.players, options.force
    end

    puts "Done."
  end


  desc "add_gameweek_players_from_snapshot", "Associate gameweek_players with gameweek_rosters based on the snapshot data"

  def add_gameweek_players_from_snapshot
    Tournament.active_tournaments.each do |tournament|
      tournament.gameweek_rosters.
                 where(gameweek: tournament.current_gameweek).
                 each do |gameweek_roster|
        gameweek_roster.add_gameweek_players
        print "."
      end
    end

    puts "Done."
  end


  desc "create_gameweek_players", "Create all GameweekPlayers for the current gameweek"

  def create_gameweek_players
    Tournament.active_tournaments.each do |tournament|
      GameweekPlayer.create_all_gameweek_players_for_gameweek tournament.current_gameweek
    end
  end


  desc "update_player_values", "Update player values based on transfers"

  def update_player_values
    Tournament.active_tournaments.each do |tournament|
      gameweek = tournament.current_gameweek

      Transfer.net_gameweek_transfers(gameweek).each do |player_id, net_transfers|
        Player.find(player_id).update_value_from_gameweek_transfers net_transfers
      end
    end
  end


  desc "update_roster_budgets", "Update all roster budgets based on player value change"

  def update_roster_budgets
    Roster.active_rosters.each(&:update_budget)
  end


  desc "update_points", "Update gameweek roster points and roster scores"
  method_option :previous, default: false, aliases: '-p', type: :boolean, desc: 'Update the previous gameweek rosters'
  method_option :region, default: "all", aliases: '-r', type: :string, desc: 'Update points for a region'

  def update_points
    print "Updating Roster scores for the "
    puts(options.previous ? "previous gameweek" : " current gameweek")
    tournaments = begin
      if ["NA", "EU"].include?(options.region)
        Tournament.active_tournaments.where(region: options.region)
      else
        Tournament.active_tournaments
      end
    end
    puts "Updating tournaments: #{tournaments.map(&:name)}"

    tournaments.each do |tournament|
      tournament.rosters.each do |roster|
        gwr = options.previous ? roster.previous_gameweek_roster : roster.current_gameweek_roster
        next unless gwr.roster_snapshot.present?

        gwr.update_points
        roster.update_score
        print "."
      end
    end

    puts "Done."
  end
end