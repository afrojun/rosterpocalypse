class Map < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :finders

  has_many :games

  validates :name, presence: true, uniqueness: true

  before_destroy :validate_destroy

  def validate_destroy
    gameCount = Game.where(map: self).count
    if gameCount > 0
      errors.add(:base, "Unable to delete #{name} since it has #{gameCount} associated #{"game".pluralize(gameCount)}.")
      throw :abort
    end
  end
end
