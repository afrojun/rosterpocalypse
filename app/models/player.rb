class Player < ApplicationRecord
  has_many :player_game_details
  has_many :games, through: :player_game_details
  has_many :heroes, through: :player_game_details
  belongs_to :team

  # This is the maximum and minimum costs that a player can have to
  # ensure that the best players don't become overly expensive and
  # all players have some value
  MIN_COST = 20
  MAX_COST = 250
end
