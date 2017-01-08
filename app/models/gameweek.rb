class Gameweek < ApplicationRecord
  belongs_to :tournament
  has_many :gameweek_players
  has_many :players, through: :gameweek_players
  has_many :gameweek_rosters
  has_many :rosters, through: :gameweek_rosters
  has_many :transfers, through: :gameweek_rosters
  has_many :games
end
