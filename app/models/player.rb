class Player < ApplicationRecord
  has_many :player_game_details
  has_many :games, through: :player_game_details
  has_many :heroes, through: :player_game_details
end
