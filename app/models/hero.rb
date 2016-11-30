class Hero < ApplicationRecord
  has_many :player_game_details
  has_many :players, through: :player_game_details
  has_many :games, through: :player_game_details

  validates :classification, inclusion: { in: ["Warrior", "Support", "Specialist", "Assassin", "Multiclass"], on: :update }
end
