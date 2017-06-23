class Roster < ApplicationRecord
  extend FriendlyId
  friendly_id :name

  belongs_to :manager
  has_and_belongs_to_many :players, -> { order "slug" }
  # For now we are limiting this to only allow one roster per league,
  # even though we can support more
  has_and_belongs_to_many :leagues, -> { order "slug" }
  belongs_to :tournament
  has_many :gameweek_rosters, dependent: :destroy
  has_many :transfers, -> { order "created_at DESC" }, through: :gameweek_rosters
  has_many :gameweeks, through: :gameweek_rosters

  validates :name, presence: true, uniqueness: true
  validates_format_of :name, with: /^[a-zA-Z0-9\- _\.]*$/, multiline: true
  validates_length_of :name, minimum: 4, maximum: 65

  after_create :create_gameweek_rosters

  MAX_PLAYERS = 5
  MAX_TOTAL_VALUE = 500

  def self.find_by_manager_and_league manager, league
    tournament_rosters = Roster.where(manager: manager, tournament: league.tournament)
    tournament_rosters.detect { |r| r.league == league }
  end

  # Dynamically define the current, previous and next gameweek and
  # gameweek_roster finder methods. This should generate 6 methods
  # for each combination of:
  # [:previous, :current, :next] * [gameweek, gameweek_roster]
  [:previous, :current, :next].each do |attribute|
    gameweek_method = :"#{attribute}_gameweek"
    gameweek_roster_method = :"#{attribute}_gameweek_roster"

    define_method gameweek_method do |safe = true|
      tournament.send gameweek_method, safe
    end

    define_method gameweek_roster_method do |safe = true|
      gameweek_rosters.where(gameweek: send(gameweek_method, safe)).first
    end
  end

  def region
    @region ||= tournament.region
  end

  def league
    leagues.first
  end

  def budget
    if league.present?
      league.starting_budget
    else
      MAX_TOTAL_VALUE
    end
  end

  def private_leagues
    @private_leagues ||= leagues.where(type: "PrivateLeague")
  end

  def public_leagues
    @public_leagues ||= leagues.where(type: "PublicLeague")
  end

  def set_available_transfers number
    gameweek_rosters.each do |gameweek_roster|
      gameweek_roster.update available_transfers: number
    end
  end

  def available_transfers
    if current_gameweek_roster.remaining_transfers > 0
      current_gameweek_roster.remaining_transfers
    else
      0
    end
  end

  def allow_free_transfers?
    players.size < MAX_PLAYERS ||
      !current_gameweek.is_tournament_week? ||
      (Time.now.utc < tournament.first_roster_lock_date)
  end

  def next_key_date
    @next_key_date ||= begin
      if current_gameweek.is_tournament_week?
        if Time.now.utc < current_gameweek.roster_lock_date
          current_gameweek.roster_lock_date
        else
          current_gameweek.end_date
        end
      else
        current_gameweek.end_date
      end
    end
  end

  def update_score
    update score: gameweek_rosters.map(&:points).compact.sum
  end

  def allow_updates?
    allow_free_transfers? || unlocked?
  end

  def unlocked?
    if roster_lock_in_place? && current_gameweek.is_tournament_week?
      errors.add(:roster, "is currently locked until the end of the Gameweek")
      false
    else
      true
    end
  end

  def full?
    players.size == MAX_PLAYERS ? true : false
  end

  def add_to league
    league.add(self) ? self : copy_errors(league)
  end

  def remove_from league
    league.remove(self) ? self : copy_errors(league)
  end

  def update_including_players params
    transaction do
      if update params.slice(:name)
        params[:players].present? ? update_players(params[:players]) : true
      else
        false
      end
    end
  end

  private

  def update_players player_ids
    # Short circuit when the players aren't changing
    return true if players.map(&:id).sort == player_ids.sort

    if allow_updates?
      if new_players = validate_roster_size(player_ids)
        if(validate_teams_active(new_players) &&
           validate_transfers(new_players) &&
           validate_player_roles(new_players) &&
           validate_players_in_same_team(new_players) &&
           validate_player_value(new_players))
          if allow_free_transfers?
            Rails.logger.info "Roster #{name}: Freely transferring in players: " +
                              "#{new_players.map(&:name)}"
            players.clear
            players << new_players
            touch
            return true
          elsif unlocked?
            players_to_add = new_players - players
            players_to_remove = players - new_players
            transfer_players players_to_add, players_to_remove
            current_gameweek_roster.create_snapshot if available_transfers < 1
            touch
            return true
          end
        end
      end
    end
    false
  end

  def transfer_players players_to_add, players_to_remove
    in_out_pairs = players_to_add.zip players_to_remove

    in_out_pairs.each do |player_in, player_out|
      Rails.logger.info "Roster #{name}: Transferring #{player_in.name} IN " +
                        "and #{player_out.name} OUT"
      transaction do
        Transfer.create(gameweek_roster: current_gameweek_roster,
                        player_in: player_in,
                        player_out: player_out)
        players.delete(player_out)
        players << player_in
      end
    end
  end

  def create_gameweek_rosters
    transaction do
      tournament.gameweeks.each do |gameweek|
        GameweekRoster.find_or_create_by gameweek: gameweek, roster: self
      end
    end
  end

  def validate_roster_size player_ids
    new_players = Player.where(id: player_ids).includes(:team)
    if new_players.size == MAX_PLAYERS
      new_players
    else
      errors.add(:roster, "must contain #{MAX_PLAYERS} players")
      false
    end
  end

  # The associated league specifies the role limitations
  def validate_player_roles players
    if league.present?
      valid = true
      league.active_required_player_role_limitations.each do |role, min|

        role_players = players.select { |player| player.role.downcase == role.to_s }
        unless role_players.size >= min
          errors.add :roster, "needs #{min} #{role} #{"player".pluralize min}"
          valid = false
        end
      end

      valid
    else
      # If no league is present, anything goes
      true
    end
  end

  def validate_players_in_same_team players
    if league.present?
      players_by_team = players.group_by(&:team)
      if players_by_team.any? { |team, players| players.size > league.max_players_per_team }
        errors.add(:roster, "may not include more than #{league.max_players_per_team} " +
                            "players from the same team")
        false
      else
        true
      end
    else
      true
    end
  end

  def validate_teams_active players
    teams = players.map(&:team).uniq
    if teams.all?(&:active)
      true
    else
      errors.add(:roster, "may not include players from inactive teams")
      false
    end
  end

  def validate_player_value players
    total_value = players.sum(&:value).round(2)
    if total_value <= budget
      true
    else
      errors.add(:roster, "may have a maximum total player value of #{budget}")
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
        errors.add(:roster, "has #{max_transfers} " +
                   "#{"transfer".pluralize(max_transfers)} available in this window")
      end
    else
      errors.add(:roster, "transfers must maintain the roster size, " +
                 "please ensure you are adding as many players as you remove")
    end
    false
  end

  def roster_lock_in_place?
    current_gameweek.roster_lock_date < Time.now.utc
  end

  def copy_errors league
    league.errors[:base].each do |message|
      errors.add(:base, message)
    end
    false
  end

end
