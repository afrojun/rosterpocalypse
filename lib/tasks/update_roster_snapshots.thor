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
  method_option :previous, default: false, aliases: '-p', type: :boolean, desc: 'Adds gameweek players for the previous gameweek'

  def add_gameweek_players_from_snapshot
    print "Adding gameweek players to gameweek rosters based on snapshots for the "
    puts(options.previous ? "previous gameweek" : " current gameweek")

    Tournament.active_tournaments.each do |tournament|
      gameweek = options.previous ? tournament.previous_gameweek : tournament.current_gameweek

      tournament.gameweek_rosters.
                 where(gameweek: gameweek).
                 each do |gameweek_roster|
        gameweek_roster.add_gameweek_players
        print "."
      end
    end

    puts "Done."
  end

  desc "create_gameweek_players", "Create all GameweekPlayers for the current gameweek"
  method_option :previous, default: false, aliases: '-p', type: :boolean, desc: 'Creates gameweek players for the previous gameweek'

  def create_gameweek_players
    print "Creating gameweek players for the "
    puts(options.previous ? "previous gameweek" : "current gameweek")

    Tournament.active_tournaments.each do |tournament|
      gameweek = options.previous ? tournament.previous_gameweek : tournament.current_gameweek
      GameweekPlayer.create_all_gameweek_players_for_gameweek gameweek
    end
    puts "Done."
  end

  desc "update_player_values", "Update player values based on transfers"

  def update_player_values
    Tournament.active_tournaments.each do |tournament|
      gameweek = tournament.current_gameweek

      Transfer.net_gameweek_transfers(gameweek).each do |player_id, net_transfers|
        gameweek_player = gameweek.gameweek_players.where(player_id: player_id).first
        gameweek_player.player.update_value_from_gameweek_transfers net_transfers
        value_change = gameweek_player.player.value - gameweek_player.value
        gameweek_player.update player_value_change: value_change.round(2)
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

  desc "update_gameweek_stats", "Update stats for the gameweek"
  method_option :previous, default: false, aliases: '-p', type: :boolean, desc: 'Use the previous gameweek'

  def update_gameweek_stats
    print "Updating Gameweek stats for the "
    puts(options.previous ? "previous gameweek" : " current gameweek")

    Tournament.active_tournaments.each do |tournament|
      gameweek = options.previous ? tournament.previous_gameweek : tournament.current_gameweek
      GameweekPlayer.update_pick_rate_and_efficiency_for_gameweek gameweek
      GameweekStatistic.update_all_stats_for_gameweek gameweek
    end
    puts "Done."
  end
end