class Map < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :finders

  has_many :games, -> { order 'start_date DESC' }

  validates :name, presence: true, uniqueness: true

  before_destroy :validate_destroy

  def duration_percentile(percentile)
    games.extend(DescriptiveStatistics).percentile(percentile, &:duration_s)
  end

  def validate_destroy
    game_count = games.size
    return unless game_count.positive?
    errors.add(:base, "Unable to delete #{name} since it has #{game_count} associated #{'game'.pluralize(game_count)}.")
    throw :abort
  end
end
