class Roster < ApplicationRecord
  extend FriendlyId
  friendly_id :name

  belongs_to :manager
  has_and_belongs_to_many :players, -> { order "slug" }
  has_and_belongs_to_many :leagues, -> { order "slug" }
  has_many :tournaments, -> { order("start_date DESC").distinct }, through: :leagues
  has_many :gameweek_rosters, dependent: :destroy
  has_many :transfers, -> { order "created_at DESC" }, through: :gameweek_rosters
  has_many :gameweeks, through: :gameweek_rosters

  validates :name, presence: true, uniqueness: true
  validates_format_of :name, with: /^[a-zA-Z0-9\- _\.]*$/, multiline: true
  validates_length_of :name, minimum: 4, maximum: 20
  validates :region, inclusion: { in: Tournament::REGIONS }

  before_validation :validate_one_roster_per_region

  MAX_PLAYERS = 5
  MAX_TOTAL_VALUE = 500

  def self.find_by_manager_and_region manager, region
    Roster.where(manager: manager, region: region).first
  end

  def gameweek_rosters_for_tournament tournament
    gameweek_rosters.where(gameweek: tournament.gameweeks)
  end

  def current_gameweeks
    tournaments.map(&:current_gameweek)
  end

  def previous_gameweeks
    tournaments.map(&:previous_gameweek)
  end

  def current_gameweek_rosters
    gameweek_rosters.where(gameweek: current_gameweeks)
  end

  def previous_gameweek_rosters
    gameweek_rosters.where(gameweek: previous_gameweeks)
  end

  def available_transfers
    current_gameweek_rosters.reduce(0) do |max, gameweek_roster|
      gameweek_roster.remaining_transfers > max ? gameweek_roster.remaining_transfers : max
    end
  end

  def allow_free_transfers?
    players.size < MAX_PLAYERS || leagues.blank? || !is_tournament_week?
  end

  def unlocked?
    if any_roster_lock_in_place? && is_tournament_week?
      errors.add(:roster, "is currently locked until the end of the Gameweek")
      false
    else
      true
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
        if allow_free_transfers?
          Rails.logger.info "Roster #{name}: Freely transferring in players: #{new_players.map(&:name)}"
          players.clear
          players << new_players
          return true
        elsif unlocked?
          players_to_add = new_players - players
          players_to_remove = players - new_players
          transfer_players players_to_add, players_to_remove
          current_gameweek_rosters.each(&:create_snapshot) if available_transfers < 1
          return true
        end
      end
    end
    false
  end

  def transfer_players players_to_add, players_to_remove
    current_gameweek_rosters.each do |gameweek_roster|
      in_out_pairs = players_to_add.zip players_to_remove

      in_out_pairs.each do |player_in, player_out|
        Rails.logger.info "Roster #{name}: Transferring #{player_in.name} IN and #{player_out.name} OUT"
        transaction do
          Transfer.create gameweek_roster: gameweek_roster, player_in: player_in, player_out: player_out
          players.delete(player_out)
          players << player_in
        end
      end
    end
  end

  def validate_one_roster_per_region
    if region_changed?
      if manager.rosters.map(&:region).include?(region)
        errors.add(:roster, "managers may only have one roster per region")
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
    if total_value <= MAX_TOTAL_VALUE
      true
    else
      errors.add(:roster, "may have a maximum total player value of #{MAX_TOTAL_VALUE}")
      false
    end
  end

  def validate_transfers new_players
    players_to_add = new_players - players
    players_to_remove = players - new_players

    if allow_free_transfers? || (players_to_add.size == players_to_remove.size)
      diff = players_to_add - players_to_remove
      max_transfers = allow_free_transfers? ? 5 : available_transfers
      if diff.size <= max_transfers
        return true
      else
        errors.add(:roster, "has #{max_transfers} #{"transfer".pluralize(max_transfers)} available in this window")
      end
    else
      errors.add(:roster, "transfers must maintain the roster size, please ensure you are adding as many players as you remove")
    end
    false
  end

  def any_roster_lock_in_place?
    current_gameweeks.any? do |gameweek|
      gameweek.roster_lock_date < Time.now
    end
  end

  def is_tournament_week?
    current_gameweeks.any? do |gameweek|
      gameweek.is_tournament_week?
    end
  end

  def copy_errors league
    league.errors[:base].each do |message|
      errors.add(:base, message)
    end
    false
  end

end
