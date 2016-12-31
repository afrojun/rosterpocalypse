class Tournament < ApplicationRecord
  extend FriendlyId
  friendly_id :name

  has_many :leagues

  validates :name, presence: true, uniqueness: true

  REGIONS = Player::REGIONS + ["Global"]
end
