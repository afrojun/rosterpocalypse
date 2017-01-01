class Map < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :finders

  has_many :games

  validates :name, presence: true, uniqueness: true

  before_destroy :validate_destroy

  def validate_destroy
    game_count = games.size
    if game_count > 0
      errors.add(:base, "Unable to delete #{name} since it has #{game_count} associated #{"game".pluralize(game_count)}.")
      throw :abort
    end
  end
end
