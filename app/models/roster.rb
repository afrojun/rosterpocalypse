class Roster < ApplicationRecord
  extend FriendlyId
  friendly_id :name

  belongs_to :manager
  has_and_belongs_to_many :players

  validates :name, presence: true, uniqueness: true

  MAX_PLAYERS = 5

  def update_including_players params
    transaction do
      response = update params.slice(:name)

      if response && params[:players].present? && params[:players].count <= MAX_PLAYERS && newPlayers = Player.where(id: params[:players])
        players.clear
        players<<newPlayers
        return true
      else
        errors.add(:rosters, "may have a maximum of #{MAX_PLAYERS} players")
        return false
      end
    end
  end

end
