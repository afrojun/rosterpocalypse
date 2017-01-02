class Tournament < ApplicationRecord
  extend FriendlyId
  friendly_id :name

  has_many :leagues
  has_many :games

  validates :name, presence: true, uniqueness: true

  REGIONS = Player::REGIONS + ["Global"]
end
