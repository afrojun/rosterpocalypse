class Game < ApplicationRecord
  extend FriendlyId
  friendly_id :game_hash

  belongs_to :map
  has_many :game_details, dependent: :destroy
  has_many :players, through: :game_details
  has_many :heroes, through: :game_details

  validates :game_hash, presence: true, uniqueness: true

  def should_generate_new_friendly_id?
    slug.blank? || game_hash_changed?
  end

end
