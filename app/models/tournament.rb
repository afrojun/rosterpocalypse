class Tournament < ApplicationRecord
  extend FriendlyId
  friendly_id :name

  has_many :leagues
  has_many :rosters, -> { distinct }, through: :leagues
  has_many :gameweeks, -> { order 'start_date ASC' }, dependent: :destroy
  has_many :games, -> { order 'start_date DESC' }, through: :gameweeks

  GLOBAL_REGION = "Global"
  REGIONS = Team::REGIONS + [GLOBAL_REGION]

  validates :name, presence: true, uniqueness: true
  validates :region, inclusion: { in: REGIONS }

  after_create :update_gameweeks
  after_update :update_gameweeks

  REGION_TIME_ZONE_MAP = {
    "CN" => "Asia/Shanghai",
    "EU" => "UTC",
    "KR" => "Asia/Seoul",
    "NA" => "America/Los_Angeles",
    "Global" => "UTC",
    "" => "UTC"
  }

  # For any time before the start of the first Gameweek, we assume that the first gameweek IS the gameweek, instead of returning nil
  def find_gameweek date
    first_gameweek = gameweeks.first
    if date < first_gameweek.start_date
      first_gameweek
    else
      gameweeks.where("start_date < ? AND end_date > ?", date, date).first
    end
  end

  def current_gameweek
    find_gameweek Time.now.utc
  end

  def previous_gameweek
    find_gameweek Time.now.utc.advance(weeks: -1)
  end

  def update_gameweeks
    create_gameweeks
    destroy_gameweeks
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

      gameweek_number = gameweek_number + 1
      gameweek_start_date = gameweek_start_date.advance(weeks: 1)
      gameweek_roster_lock_date = gameweek_roster_lock_date.advance(weeks: 1)
    end
  end

  def destroy_gameweeks
    # Gameweeks where the Tournament start_date is after the Gameweek end_date OR the Gameweek start_date is after the Tournament end_date
    gameweeks.where("start_date > ? OR end_date < ?", end_date, start_date - 1.week).each do |gameweek|
      if gameweek.games.blank? && gameweek.gameweek_rosters.blank? && gameweek.gameweek_players.blank?
        Rails.logger.info "Destroying orphaned gameweek: #{gameweek.inspect}."
        gameweek.destroy
      else
        Rails.logger.info "Unable to delete orphaned Gameweek since there are still some resources referring to it: #{gameweek.inspect}."
      end
    end
  end

end
