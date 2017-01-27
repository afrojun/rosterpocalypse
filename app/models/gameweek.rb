class Gameweek < ApplicationRecord
  belongs_to :tournament
  has_many :gameweek_players, dependent: :destroy
  has_many :players, through: :gameweek_players
  has_many :gameweek_rosters, dependent: :destroy
  has_many :rosters, through: :gameweek_rosters
  has_many :transfers, through: :gameweek_rosters
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
    tournament.find_gameweek start_date.advance(weeks: 1), false
  end

  def previous
    tournament.find_gameweek start_date.advance(weeks: -1), false
  end

  def points_percentile percentile
    gameweek_rosters.extend(DescriptiveStatistics).percentile(percentile) { |gameweek_roster| gameweek_roster.points }
  end
end
