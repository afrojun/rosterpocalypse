class Roster < ApplicationRecord
  extend FriendlyId
  friendly_id :name

  belongs_to :manager
  has_many :players, through: :roster_players

  validates :name, presence: true, uniqueness: true
end
