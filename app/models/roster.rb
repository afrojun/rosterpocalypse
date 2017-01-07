class Roster < ApplicationRecord
  extend FriendlyId
  friendly_id :name

  belongs_to :manager
  has_and_belongs_to_many :players, -> { order "slug" }
  has_and_belongs_to_many :leagues, -> { order "slug" }
  has_many :tournaments, -> { distinct }, through: :leagues
  has_many :transfers, dependent: :destroy
  has_many :gameweek_rosters, dependent: :destroy
  has_many :gameweeks, through: :gameweek_rosters

  validates :name, presence: true, uniqueness: true
  validates_format_of :name, with: /^[a-zA-Z0-9\- _\.]*$/, multiline: true
  validates_length_of :name, minimum: 4, maximum: 20
  validates :region, inclusion: { in: Tournament::REGIONS }

  before_validation :validate_one_roster_per_region

  MAX_PLAYERS = 5
  MAX_TOTAL_VALUE = 500
  DEFAULT_TRANSFERS_PER_GAMEWEEK = 1
  TRANSFERS_IN_FIRST_GAMEWEEK = 5

  def self.find_by_manager_and_region manager, region
    Roster.where(manager: manager, region: region).first
  end

  def validate_one_roster_per_region
    if region_changed?
      if manager.rosters.map(&:region).include?(region)
        errors.add(:base, "Managers may only have one roster per region.")
        throw :abort
      end
    end
  end

  def gameweek_rosters_for_tournament tournament
    gameweek_rosters.where(gameweek: tournament.gameweeks)
  end

  def current_gameweeks
    tournaments.map(&:current_gameweek)
  end

  def available_transfers
    current_gameweeks.reduce(DEFAULT_TRANSFERS_PER_GAMEWEEK) do |max, gameweek|
      gameweek_roster = gameweek_rosters.where(gameweek: gameweek).first
      max = gameweek_roster.available_transfers if gameweek_roster.present? && gameweek_roster.available_transfers > max
    end
  end

  def update_including_players params
    transaction do
      if update params.slice(:name, :region)
        if params[:players].present?
          if validate_roster_size params[:players]
            new_players = Player.where(id: params[:players])
            if validate_player_roles(new_players) && validate_player_value(new_players)
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

  def validate_player_value players
    total_value = players.sum(&:value)
    if total_value < MAX_TOTAL_VALUE
      true
    else
      errors.add(:rosters, "have a maximum total player value of #{MAX_TOTAL_VALUE}")
      false
    end
  end

end
