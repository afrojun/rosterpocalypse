class Team < ApplicationRecord
  extend FriendlyId
  friendly_id :name

  has_many :game_details
  has_many :games, through: :game_details
  has_many :alternate_names, class_name: "TeamAlternateName", dependent: :destroy
  has_many :players

  validates :name, presence: true, uniqueness: true

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

end
