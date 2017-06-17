class League < ApplicationRecord
  extend FriendlyId
  friendly_id :name

  belongs_to :manager
  belongs_to :tournament
  has_and_belongs_to_many :rosters
  has_many :gameweek_rosters, -> { distinct }, through: :rosters

  validates :name, presence: true, uniqueness: true
  validates_format_of :name, with: /^[a-zA-Z0-9\/\- _\.]*$/, multiline: true
  validates_length_of :name, minimum: 4, maximum: 30
  validates :type, presence: true

  def roster_rank roster
    rosters.select(:id, :score).order(score: :desc).to_a.index(roster).try(:+, 1)
  end

  def historic_roster_rank gameweek, roster
    league_gameweek_rosters = gameweek_rosters.select(:id, :points).where(gameweek: gameweek).order(points: :desc).to_a
    gameweek_roster = roster.gameweek_rosters.where(gameweek: gameweek).first
    league_gameweek_rosters.index(gameweek_roster).try(:+, 1)
  end

  def join manager
    if tournament.active?
      if validate_one_roster_per_league manager
        roster_name = "#{manager.slug}_#{slug}"
        roster = Roster.create(name: roster_name, tournament: tournament, manager: manager)
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

  def leave manager
    if roster = rosters.where(manager: manager).first
      Rails.logger.info "Removing Roster '#{roster.slug}' from League '#{slug}'."
      remove roster
      roster.destroy
    else
      errors.add(:base, "You do not have any Rosters in this League.")
      false
    end
  end

  def add roster
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

  def remove roster
    rosters.delete roster
    true
  end

  private

  def validate_one_roster_per_league manager
    if manager.rosters.map(&:leagues).flatten.include?(self)
      message = "Only one roster per manager is allowed in a League."
      errors.add(:base, message)
      Rails.logger.warn message
      false
    else
      true
    end
  end

end
