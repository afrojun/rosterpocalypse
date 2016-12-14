class Game < ApplicationRecord
  extend FriendlyId
  friendly_id :game_hash

  belongs_to :map
  has_many :player_game_details, dependent: :destroy
  has_many :players, through: :player_game_details
  has_many :heroes, through: :player_game_details

  def should_generate_new_friendly_id?
    slug.blank? || game_hash_changed?
  end

end
