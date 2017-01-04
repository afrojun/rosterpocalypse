class Game < ApplicationRecord
  extend FriendlyId
  friendly_id :game_hash

  belongs_to :map
  belongs_to :tournament
  has_many :game_details, dependent: :destroy
  has_many :players, through: :game_details
  has_many :heroes, through: :game_details

  validates :game_hash, presence: true, uniqueness: true

  def should_generate_new_friendly_id?
    slug.blank? || game_hash_changed?
  end

  def swap_teams
    teams = game_details.map(&:team).uniq
    if teams.size == 2
      transaction do
        game_details.each do |detail|
          new_team = (teams - [detail.team]).first
          detail.update_attribute(:team, new_team)
        end
      end
    else
      errors.add(:base, "Only games with exactly 2 teams can be swapped.")
      false
    end

  end
end
