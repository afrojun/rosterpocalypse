class Hero < ApplicationRecord
  extend FriendlyId
  friendly_id :name

  has_many :player_game_details
  has_many :players, through: :player_game_details
  has_many :games, through: :player_game_details

  HERO_CLASSIFICATIONS = ["Warrior", "Support", "Specialist", "Assassin", "Multiclass"]

  validates :name, presence: true, uniqueness: true
  validates :internal_name, presence: true, uniqueness: true
  validates :classification, inclusion: { in: HERO_CLASSIFICATIONS + ["", nil] }

end
