class Tournament < ApplicationRecord
  extend FriendlyId
  friendly_id :name

  has_many :leagues
  has_many :games

  REGIONS = Team::REGIONS + ["Global"]

  validates :name, presence: true, uniqueness: true
  validates :region, inclusion: { in: REGIONS }
end
