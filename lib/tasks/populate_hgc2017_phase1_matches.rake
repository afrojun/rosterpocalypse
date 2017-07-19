desc 'This is a one-off task to create matches for the first phase of HGC 2017.'

task populate_hgc2017_phase1_matches: :environment do
  cal_path = Rails.root.join('app', 'assets', 'calendars', 'hgc2017-phase1.ics')
  puts "Using calendar: #{cal_path}"
  cal_file = File.open(cal_path)
  events = Icalendar::Event.parse(cal_file)

  events.each do |event|
    if ['bye week', 'mid-season brawl', 'hgc crucible', 'hgc playoffs', 'eastern clash', 'western clash'].include?(event.summary.downcase)
      puts "Skipping Event: #{event.summary}"
      next
    end

    _summary, region, team_1_name, team_2_name = event.summary.match(/^(\w{2}) - (.+) vs. (.+)$/).to_a

    puts "region: #{region}; team_1_name: #{team_1_name}; team_2_name: #{team_2_name}; event.dtstart: #{event.dtstart}"
    if region && team_1_name && team_2_name && event.dtstart
      tournament = Tournament.active_tournaments.where(region: region).first
      date = Time.parse(event.dtstart.to_s).utc

      stage = Stage.find_or_create_by(
        name: 'League Play',
        tournament: tournament
      )

      Match.find_or_create_by(
        team_1: Team.find_including_alternate_names(team_1_name).first,
        team_2: Team.find_including_alternate_names(team_2_name).first,
        gameweek: tournament.find_gameweek(date),
        stage: stage,
        start_date: date,
        best_of: 5
      )
      puts 'Match loaded successfully.'
    else
      puts "ERROR: Unable to load match - #{event.summary}"
    end
  end
end
