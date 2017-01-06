class Tournament < ApplicationRecord
  extend FriendlyId
  friendly_id :name

  has_many :leagues
  has_many :games

  GLOBAL_REGION = "Global"
  REGIONS = Team::REGIONS + [GLOBAL_REGION]

  validates :name, presence: true, uniqueness: true
  validates :region, inclusion: { in: REGIONS }
end
