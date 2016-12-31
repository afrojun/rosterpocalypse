class League < ApplicationRecord
  extend FriendlyId
  friendly_id :name

  belongs_to :manager
  belongs_to :tournament
  has_and_belongs_to_many :rosters

  validates :name, presence: true, uniqueness: true
  validates :type, presence: true
end
