class Roster < ApplicationRecord
  extend FriendlyId
  friendly_id :name

  belongs_to :manager
  has_and_belongs_to_many :players

  validates :name, presence: true, uniqueness: true

  def update params
    transaction do
      update_attribute(:name, params[:name]) if params[:name].present?

      if params[:players].present? && params[:players].count <= 5 && newPlayers = Player.where(id: params[:players])
        players.clear
        players<<newPlayers
      else
        errors.add(:rosters, "may have a maximum of 5 players")
        return false
      end
    end

  end
end
