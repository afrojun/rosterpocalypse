class Team < ApplicationRecord
  has_many :team_alternate_names, dependent: :destroy
  has_many :players

  validates :name, presence: true, uniqueness: true

  after_create :update_team_alternate_names
  after_update :update_team_alternate_names

  def update_team_alternate_names
    TeamAlternateName.create(team: self, alternate_name: name) unless team_alternate_names.map(&:alternate_name).include?(name)
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
