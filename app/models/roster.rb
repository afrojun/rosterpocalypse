class Roster < ApplicationRecord
  extend FriendlyId
  friendly_id :name

  belongs_to :manager
  has_and_belongs_to_many :players, -> { order "slug" }
  has_and_belongs_to_many :leagues, -> { order "slug" }
  has_many :tournaments, -> { distinct }, through: :leagues
  has_many :gameweek_rosters, dependent: :destroy
  has_many :transfers, through: :gameweek_rosters
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

  def gameweek_rosters_for_tournament tournament
    gameweek_rosters.where(gameweek: tournament.gameweeks)
  end

  def current_gameweeks
    tournaments.map(&:current_gameweek)
  end

  def current_gameweek_rosters
    gameweek_rosters.where(gameweek: current_gameweeks)
  end

  def available_transfers
    current_gameweek_rosters.reduce(DEFAULT_TRANSFERS_PER_GAMEWEEK) do |max, gameweek_roster|
      gameweek_roster.available_transfers > max ? gameweek_roster.available_transfers : max
    end
  end

  def add_to league
    league.add(self) ? self : copy_errors(league)
  end

  def remove_from league
    league.remove(self) ? self : copy_errors(league)
  end

  def update_including_players params
    transaction do
      if update params.slice(:name, :region)
        params[:players].present? ? update_players(params[:players]) : true
      else
        false
      end
    end
  end

  private

  def update_players player_ids
    if new_players = validate_roster_size(player_ids)
      if validate_transfers(new_players) && validate_player_roles(new_players) && validate_player_value(new_players)
        players_to_add = new_players - players
        players.clear
        players << new_players
        return true
      end
    end
    false
  end

  def validate_one_roster_per_region
    if region_changed?
      if manager.rosters.map(&:region).include?(region)
        errors.add(:base, "Managers may only have one roster per region.")
        throw :abort
      end
    end
  end

  def validate_roster_size player_ids
    new_players = Player.where(id: player_ids)
    if new_players.size == MAX_PLAYERS
      new_players
    else
      errors.add(:roster, "must contain #{MAX_PLAYERS} players")
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
      errors.add(:roster, "needs to include at least one dedicated Support player") unless support_present
      errors.add(:roster, "needs to include at least one dedicated Warrior player") unless warrior_present
      false
    end
  end

  def validate_player_value players
    total_value = players.sum(&:value)
    if total_value < MAX_TOTAL_VALUE
      true
    else
      errors.add(:roster, "may have a maximum total player value of #{MAX_TOTAL_VALUE}")
      false
    end
  end

  def validate_transfers new_players
    diff = new_players - players

    max_transfers = allow_free_transfers? ? 5 : available_transfers
    if diff.size <= max_transfers
      true
    else
      errors.add(:roster, "has #{max_transfers} #{"transfer".pluralize(max_transfers)} available in this window")
      false
    end
  end

  def update_available_transfers num_transfers_completed
    current_gameweek_rosters.each do |gameweek_roster|
      new_available_transfers = gameweek_roster.available_transfers - num_transfers_completed
      adjusted_transfers = new_available_transfers < 0 ? 0 : new_available_transfers
      gameweek_roster.update_attribute :available_transfers, adjusted_transfers
    end
  end

  def allow_free_transfers?
    players.size < MAX_PLAYERS || leagues.blank? || !any_tournaments_in_progress?
  end

  def any_tournaments_in_progress?
    tournaments.any? do |tournament|
      tournament.start_date < Time.now
    end
  end

  def copy_errors league
    league.errors[:base].each do |message|
      errors.add(:base, message)
    end
    false
  end

end
