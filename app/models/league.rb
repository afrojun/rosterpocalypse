class League < ApplicationRecord
  extend FriendlyId
  friendly_id :name

  belongs_to :manager
  belongs_to :tournament
  has_and_belongs_to_many :rosters
  has_many :league_gameweek_players, dependent: :destroy
  has_many :gameweek_rosters, -> { distinct }, through: :rosters
  has_many :gameweek_players, through: :league_gameweek_players

  validates :name, presence: true, uniqueness: true
  validates :name, format: { with: /^[a-zA-Z0-9\/\- _\.]*$/, multiline: true }
  validates :name, length: { minimum: 4, maximum: 30 }
  validates :tournament, presence: true
  validates :type, presence: true
  validates :starting_budget, presence: true
  validates :num_transfers, presence: true
  validates :max_players_per_team, presence: true
  validates :role_stat_modifiers, presence: true
  validates :required_player_roles, presence: true

  validate :limit_active_leagues_per_manager, on: :create
  validate :check_required_player_roles, on: :create

  serialize :role_stat_modifiers,   Hash
  serialize :required_player_roles, Hash

  MAX_ACTIVE_LEAGUES_PER_MANAGER = 10

  DEFAULT_ROLE_STAT_MODIFIERS = {
    "assassin" => { "solo_kills" => "2", "assists" => "1", "time_spent_dead" => "20", "win" => "5" },
    "flex"     => { "solo_kills" => "2", "assists" => "1", "time_spent_dead" => "20", "win" => "5" },
    "warrior"  => { "solo_kills" => "1", "assists" => "1", "time_spent_dead" => "40", "win" => "5" },
    "support"  => { "solo_kills" => "1", "assists" => "1", "time_spent_dead" => "30", "win" => "5" },
  }.freeze

  DEFAULT_REQUIRED_PLAYER_ROLES = {
    "assassin" => "0",
    "flex"     => "0",
    "warrior"  => "1",
    "support"  => "1",
  }.freeze

  def self.active_leagues
    includes(:tournament).
      where(tournament: Tournament.active_tournaments).
      order("manager_id asc")
  end

  # Override name setter to strip whitespace
  def name=(nom)
    super(nom.squish)
  end

  def populate_default_options
    if role_stat_modifiers.blank?
      update role_stat_modifiers: DEFAULT_ROLE_STAT_MODIFIERS
    end

    if required_player_roles.blank?
      update required_player_roles: DEFAULT_REQUIRED_PLAYER_ROLES
    end
  end

  def numeric_required_player_roles
    @numeric_required_player_roles ||= {}.tap do |req|
      required_player_roles.each do |role, num|
        req[role] = num.to_i
      end
    end
  end

  def active_required_player_role_limitations
    numeric_required_player_roles.select do |role, num|
      num > 0
    end
  end

  # If any of the role_stat_modifiers are negative numbers, we assume that
  # the league admin allows overall roster scores to also be negative
  def allow_negative_scores?
    role_stat_modifiers.values.map(&:values).flatten.uniq.sort.first.to_i < 0
  end

  def roster_rank(roster)
    rosters.select(:id, :score).order(score: :desc).to_a.index(roster).try(:+, 1)
  end

  def historic_roster_rank(gameweek, roster)
    league_gameweek_rosters = gameweek_rosters.select(:id, :points).where(gameweek: gameweek).order(points: :desc).to_a
    gameweek_roster = roster.gameweek_rosters.find_by(gameweek: gameweek)
    league_gameweek_rosters.index(gameweek_roster).try(:+, 1)
  end

  def join(manager)
    if tournament.active?
      if validate_one_roster_per_league manager
        roster_name = "#{manager.slug}_#{slug}"
        roster = Roster.create(name: roster_name, tournament: tournament,
                               manager: manager, budget: starting_budget)
        roster.set_available_transfers num_transfers
        Rails.logger.info "Creating and adding Roster '#{roster.slug}' to League '#{slug}'."
        add(roster) && roster
      else
        false
      end
    else
      message = "Unable to join a league for an inactive tournament."
      errors.add(:base, message)
      Rails.logger.warn message
      false
    end
  end

  def leave(manager)
    if roster = rosters.find_by(manager: manager)
      Rails.logger.info "Removing Roster '#{roster.slug}' from League '#{slug}'."
      remove roster
      roster.destroy
    else
      errors.add(:base, "You do not have any Rosters in this League.")
      false
    end
  end

  def add(roster)
    if validate_one_roster_per_league roster.manager
      if roster.tournament == tournament
        rosters << roster
        true
      else
        message = "Unable to add Roster '#{roster.slug}' to League '#{slug}' since they are not for the same tournament."
        errors.add(:base, message)
        Rails.logger.warn message
        false
      end
    else
      false
    end
  end

  def remove(roster)
    rosters.delete roster
    true
  end

  private

  def check_required_player_roles
    if required_player_roles.values.map(&:to_i).sum > 5
      message = "role requirement specification is invalid. The maximum total value across all roles is 5."
      errors.add(:league, message)
      Rails.logger.warn message
      false
    end
  end

  def limit_active_leagues_per_manager
    active_leagues_for_manager = manager.leagues.
                                         includes(:tournament).
                                         where(tournament: Tournament.active_tournaments)

    if !manager.user.admin? && active_leagues_for_manager.size >= MAX_ACTIVE_LEAGUES_PER_MANAGER
      message = "Creating more than #{MAX_ACTIVE_LEAGUES_PER_MANAGER} active leagues per manager is not permitted."
      Rails.logger.warn message
      errors.add(:base, message)
      false
    end
  end

  def validate_one_roster_per_league(manager)
    if manager.roster_leagues.include?(self)
      message = "Only one roster per manager is allowed in a League."
      errors.add(:base, message)
      Rails.logger.warn message
      false
    else
      true
    end
  end
end
