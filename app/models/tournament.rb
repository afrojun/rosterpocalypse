class Tournament < ApplicationRecord
  extend FriendlyId
  friendly_id :name

  has_many :leagues
  has_many :rosters, -> { distinct }, through: :leagues
  has_many :gameweeks, dependent: :destroy
  has_many :games, -> { order 'start_date DESC' }, through: :gameweeks

  GLOBAL_REGION = "Global"
  REGIONS = Team::REGIONS + [GLOBAL_REGION]

  validates :name, presence: true, uniqueness: true
  validates :region, inclusion: { in: REGIONS }

  after_create :create_gameweeks

  REGION_TIME_ZONE_MAP = {
    "CN" => "Asia/Shanghai",
    "EU" => "UTC",
    "KR" => "Asia/Seoul",
    "NA" => "America/Los_Angeles",
    "Global" => "UTC",
    "" => "UTC"
  }

  def current_gameweek
    now = Time.now
    gameweeks.where("start_date < ? AND end_date > ?", now, now).first
  end

  def create_gameweeks
    # Gameweeks start 1 week prior to the Tournament start to allow creation of rosters
    gameweek_number = 0
    # Gameweeks start at midday UTC on Mondays
    gameweek_start_date = start_date.beginning_of_week.advance(weeks: -1) + 12.hours
    # Lock rosters at noon on Friday in the timezone of the tournament. We need to add extra checks to ensure that
    # the timezone change doesn't make the roster_lock dates move to a different week
    gameweek_start_date_in_timezone = start_date.in_time_zone(REGION_TIME_ZONE_MAP[region]).beginning_of_week.advance(weeks: -1) + 12.hours
    day_diff = ((gameweek_start_date - gameweek_start_date_in_timezone) / 1.day).round
    gameweek_roster_lock_date = gameweek_start_date_in_timezone.advance(days: 4 + day_diff)

    while gameweek_start_date < end_date
      gameweek_name = "Gameweek #{gameweek_number}"
      gameweek_end_date = gameweek_start_date.end_of_week

      Gameweek.create(
        name: gameweek_name,
        tournament: self,
        start_date: gameweek_start_date,
        roster_lock_date: gameweek_number > 0 ? gameweek_roster_lock_date : nil,
        end_date: gameweek_end_date
      )

      gameweek_number = gameweek_number + 1
      gameweek_start_date = gameweek_start_date.advance(weeks: 1)
      gameweek_roster_lock_date = gameweek_roster_lock_date.advance(weeks: 1)
    end
  end

end
