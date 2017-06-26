class Gameweek < ApplicationRecord
  belongs_to :tournament
  has_one :gameweek_statistic, dependent: :destroy
  has_many :gameweek_players, dependent: :destroy
  has_many :players, through: :gameweek_players
  has_many :gameweek_rosters, dependent: :destroy
  has_many :rosters, through: :gameweek_rosters
  has_many :transfers, through: :gameweek_rosters
  has_many :leagues, through: :tournament
  has_many :games, -> { order "games.start_date ASC" }
  has_many :matches, -> { order "matches.start_date ASC" }, dependent: :destroy

  def name_including_dates
    format = "%Y-%m-%d"
    "#{name}: #{start_date.strftime(format)} - #{end_date.strftime(format)} (#{games.size})"
  end

  # Is the tournament running this week? This is used to filter out the first/last weeks
  def is_tournament_week?
    end_date > tournament.start_date
  end

  def next
    tournament.find_gameweek end_date.advance(days: 1), false
  end

  def next_active gameweek = self.next
    if gameweek.blank?
      return nil
    else
      gameweek.matches.any? ? gameweek : next_active(gameweek.next)
    end
  end

  def previous
    tournament.find_gameweek start_date.advance(days: -1), false
  end

  def previous_active gameweek = self.previous
    if gameweek.blank?
      return nil
    else
      gameweek.matches.any? ? gameweek : previous_active(gameweek.previous)
    end
  end

  def points_percentile percentile
    gameweek_rosters.extend(DescriptiveStatistics).percentile(percentile) { |gameweek_roster| gameweek_roster.points }
  end

  def move_end_date offset
    next_gameweek = self.next
    update end_date: end_date+offset
    next_gameweek.update start_date: next_gameweek.start_date+offset
  end

  def update_all_gameweek_players
    gameweek_players.each(&:update_all_games)
  end

  def update_all_gameweek_rosters
    gameweek_rosters.each(&:update_points)
  end
end
