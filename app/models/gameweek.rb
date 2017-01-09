class Gameweek < ApplicationRecord
  belongs_to :tournament
  has_many :gameweek_players
  has_many :players, through: :gameweek_players
  has_many :gameweek_rosters
  has_many :rosters, through: :gameweek_rosters
  has_many :transfers, through: :gameweek_rosters
  has_many :games, -> { order "start_date DESC" }

  def name_including_dates
    format = "%Y-%m-%d"
    "#{name}: #{start_date.strftime(format)} - #{end_date.strftime(format)} (#{games.size})"
  end

  # Is the tournament running this week? This is used to filter out the first/last weeks
  def is_tournament_week?
    end_date > tournament.start_date
  end
end
