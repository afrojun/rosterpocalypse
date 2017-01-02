class Roster < ApplicationRecord
  extend FriendlyId
  friendly_id :name

  belongs_to :manager
  has_and_belongs_to_many :players
  has_and_belongs_to_many :leagues

  validates :name, presence: true, uniqueness: true
  validates :region, inclusion: { in: Tournament::REGIONS }

  before_validation :validate_one_roster_per_region

  MAX_PLAYERS = 5
  MAX_TOTAL_COST = 500

  def self.find_by_manager_and_region manager, region
    Roster.where(manager: manager, region: region).first
  end

  def validate_one_roster_per_region
    if manager.rosters.map(&:region).include?(region)
      errors.add(:base, "Managers may only have one roster per region.")
      throw :abort
    end
  end

  def update_including_players params
    transaction do
      if update params.slice(:name, :region)
        if params[:players].present?
          if validate_roster_size params[:players]
            new_players = Player.where(id: params[:players])
            if validate_player_roles(new_players) && validate_player_cost(new_players)
              players.clear
              players<<new_players
              return true
            end
          end
        else
          return true
        end
      end

      return false
    end
  end

  private

  def validate_roster_size player_ids
    if player_ids.count <= MAX_PLAYERS
      Player.where(id: player_ids).present?
    else
      errors.add(:rosters, "may have a maximum of #{MAX_PLAYERS} players")
      false
    end
  end

  # Require at least 1 Supprt and 1 Warrior player on all teams
  def validate_player_roles players
    support_present = players.any? { |player| player.role == "Support" }
    warrior_present = players.any? { |player| player.role == "Warrior" }
    if support_present && warrior_present
      true
    else
      errors.add(:rosters, "need to include at least one dedicated Support player") unless support_present
      errors.add(:rosters, "need to include at least one dedicated Warrior player") unless warrior_present
      false
    end
  end

  def validate_player_cost players
    total_cost = players.sum(&:cost)
    if total_cost < MAX_TOTAL_COST
      true
    else
      errors.add(:rosters, "have a maximum total player cost of #{MAX_TOTAL_COST}")
      false
    end
  end

end
