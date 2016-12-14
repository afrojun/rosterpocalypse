class Roster < ApplicationRecord
  extend FriendlyId
  friendly_id :name

  belongs_to :manager
  has_and_belongs_to_many :players

  validates :name, presence: true, uniqueness: true
end
