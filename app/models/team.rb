class Team < ApplicationRecord
  extend FriendlyId
  friendly_id :name

  has_many :game_details
  has_many :games, through: :game_details
  has_many :alternate_names, class_name: "TeamAlternateName", dependent: :destroy
  has_many :players

  REGIONS = %w{ CN EU KR NA }

  validates :name, presence: true, uniqueness: true
  validates :region, inclusion: { in: REGIONS + [nil, ""] }

  after_create :update_alternate_names
  after_update :update_alternate_names
  before_destroy :validate_destroy

  def update_alternate_names
    TeamAlternateName.find_or_create_by(team: self, alternate_name: name)
  end

  def validate_destroy
    game_count = game_details.size
    if game_count > 0
      errors.add(:base, "Unable to delete #{name} since it has #{game_count} associated #{"game".pluralize(game_count)}.")
      throw :abort
    end
  end

  def self.find_or_create_including_alternate_names team_name
    alternate_names = TeamAlternateName.where(alternate_name: team_name)
    if alternate_names.any?
      alternate_names.first.team
    else
      Team.find_or_create_by name: team_name
    end
  end

  def merge! other_team
    transaction do
      # Save the alternate names to add them to this team once the other team is destroyed
      other_team_alternate_names = other_team.alternate_names.map(&:alternate_name)

      # Change all game details for the merged team to point to this team
      other_team.game_details.each do |detail|
        detail.update_attribute(:team, self)
      end

      # Replace the team in any associated Players
      other_team.players.each do |player|
        player.update_attribute(:team, self)
      end

      # Destroy the old team
      other_team.destroy

      # Finally add the merged team's alternate names to the primary
      other_team_alternate_names.each do |alt_name|
        TeamAlternateName.find_or_create_by(team: self, alternate_name: alt_name)
      end
    end
  end

end
