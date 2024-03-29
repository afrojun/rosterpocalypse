class Tournament < ApplicationRecord
  extend FriendlyId
  friendly_id :name

  has_many :leagues
  has_many :rosters
  has_many :stages
  has_many :gameweeks, -> { order 'start_date ASC' }, dependent: :destroy
  has_many :games, -> { order 'start_date ASC' }, through: :gameweeks
  has_many :matches, -> { order 'start_date ASC' }, through: :gameweeks
  has_many :gameweek_rosters, through: :gameweeks

  GLOBAL_REGION = 'Global'.freeze
  REGIONS = Team::REGIONS + [GLOBAL_REGION]

  validates :name, presence: true, uniqueness: true
  validates :region, inclusion: { in: REGIONS }

  after_create :create_gameweeks

  REGION_TIME_ZONE_MAP = {
    'CN' => 'Asia/Shanghai',
    'EU' => 'UTC',
    'KR' => 'Asia/Seoul',
    'NA' => 'America/Los_Angeles',
    'ANZ' => 'Australia/Melbourne',
    'TW' => 'Asia/Taipei',
    'LAM' => 'America/Sao_Paulo',
    'SEA' => 'Asia/Singapore',
    'Global' => 'UTC',
    '' => 'UTC'
  }.freeze

  # Show active tournaments or fallback to showing the 2 most recently completed tournaments.
  def self.active_tournaments
    tournaments = Tournament.where('end_date > ?', Time.now.utc)
    tournaments.any? ? tournaments : Tournament.order(:end_date).last(2)
  end

  def active?
    @active ||= end_date > Time.now.utc
  end

  def first_roster_lock_date
    @first_roster_lock_date ||= find_gameweek(start_date).roster_lock_date
  end

  # The 'safe' parameter denotes whether we allow the value to be nil
  # When 'safe', we always return a gameweek, the first one for dates before the start
  # of the tournament, and the last one for dates after the end of the tournament
  def find_gameweek(date, safe = true)
    gameweek = gameweeks.find_by('start_date <= ? AND end_date >= ?', date, date)

    if safe && gameweek.nil?
      first_gameweek = gameweeks.first
      return first_gameweek if date < first_gameweek.start_date

      last_gameweek = gameweeks.last
      return last_gameweek if date > last_gameweek.end_date
    end

    gameweek
  end

  def next_gameweek(safe = true)
    @next_gameweek ||= find_gameweek current_gameweek.end_date.advance(days: 1), safe
  end

  def current_gameweek(safe = true)
    @current_gameweek ||= find_gameweek Time.now.utc, safe
  end

  def previous_gameweek(safe = true)
    @previous_gameweek ||= find_gameweek current_gameweek.start_date.advance(days: -1), safe
  end

  def private_leagues
    @private_leagues ||= leagues.where(type: 'PrivateLeague')
  end

  def public_leagues
    @public_leagues ||= leagues.where(type: 'PublicLeague')
  end

  def create_gameweeks
    gameweek_number = 0
    # Gameweeks start at midday UTC on Mondays
    gameweek_start_date = start_date.beginning_of_week - 1.week + 12.hours
    # Lock rosters at noon on Friday in the timezone of the tournament. We need to add extra checks to ensure that
    # the timezone change doesn't make the roster_lock dates move to a different week
    gameweek_start_date_in_timezone = start_date.in_time_zone(REGION_TIME_ZONE_MAP[region]).beginning_of_week - 1.week + 12.hours
    day_diff = ((gameweek_start_date - gameweek_start_date_in_timezone) / 1.day).round
    gameweek_roster_lock_date = gameweek_start_date_in_timezone.advance(days: 4 + day_diff)

    while gameweek_start_date < end_date
      gameweek_name = "Gameweek #{gameweek_number}"
      gameweek_end_date = gameweek_start_date.end_of_week + 12.hours

      gameweek = Gameweek.find_or_initialize_by tournament: self, start_date: gameweek_start_date, end_date: gameweek_end_date
      gameweek.update_attributes! name: gameweek_name, roster_lock_date: gameweek_roster_lock_date

      gameweek_number += 1
      gameweek_start_date = gameweek_start_date.advance(weeks: 1)
      gameweek_roster_lock_date = gameweek_roster_lock_date.advance(weeks: 1)
    end
  end
end
