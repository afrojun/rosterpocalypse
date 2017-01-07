class League < ApplicationRecord
  extend FriendlyId
  friendly_id :name

  belongs_to :manager
  belongs_to :tournament
  has_and_belongs_to_many :rosters

  validates :name, presence: true, uniqueness: true
  validates_format_of :name, with: /^[a-zA-Z0-9\- _\.]*$/, multiline: true
  validates_length_of :name, minimum: 4, maximum: 20
  validates :type, presence: true

  def join manager
    if roster = Roster.find_by_manager_and_region(manager, tournament.region)
      Rails.logger.info "Adding Roster '#{roster.name}' to League '#{name}'."
      add(roster) && roster
    else
      errors.add(:base, "You do not have a Roster for the '#{tournament.region}' region, please create one and try again.")
      false
    end
  end

  def leave manager
    if roster = rosters.where(manager: manager).first
      Rails.logger.info "Removing Roster '#{roster.name}' from League '#{name}'."
      remove(roster) && roster
    else
      errors.add(:base, "You do not have any Rosters in this League.")
      false
    end
  end

  def add roster
    transaction do
      rosters << roster
      tournament.gameweeks.order(start_date: :asc).each_with_index do |gameweek, index|
        GameweekRoster.find_or_create_by gameweek: gameweek, roster: roster
      end
    end
    true
  end

  def remove roster
    if roster.leagues.size > 1
      transaction do
        # If the roster is not in any other leagues for this tournament, destroy all remaining
        # GameweekRosters for which points have not yet been calculated
        rosters.delete roster
        roster.gameweek_rosters_for_tournament(tournament).where(points: nil).each(&:destroy) unless tournament.rosters.include?(roster)
      end
      true
    else
      message = "Unable to leave league, rosters need to be in at least one league."
      errors.add(:base, message)
      Rails.logger.warn message
      false
    end
  end
end
