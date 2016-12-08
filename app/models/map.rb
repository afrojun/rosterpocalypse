class Map < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :finders

  has_many :games

  validates :name, presence: true, uniqueness: true
end
