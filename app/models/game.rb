class Game < ApplicationRecord
  extend FriendlyId
  friendly_id :game_hash

  belongs_to :map
  belongs_to :gameweek
  has_one :tournament, through: :gameweek
  has_many :game_details, dependent: :destroy
  has_many :players, through: :game_details
  has_many :heroes, through: :game_details
  has_many :teams, -> { distinct }, through: :game_details

  validates :game_hash, presence: true, uniqueness: true

  def self.team_stat_percentile stat, percentile
    team_stats = Game.all.includes(game_details: [:team]).map { |game| game.team_stats.values }.flatten
    team_stats.extend(DescriptiveStatistics).percentile(percentile) { |team_stat| team_stat[stat.to_sym] }
  end

  def team_stats
    Hash.new.tap do |stats|
      game_details.to_a.group_by(&:team_id).each do |_, details|
        team_name = details.first.team.name
        stats[team_name] = {
          kills: details.sum(&:solo_kills),
          deaths: details.sum(&:deaths)
        }
      end
    end
  end

  def should_generate_new_friendly_id?
    slug.blank? || game_hash_changed?
  end

  def teams
    @teams ||= game_details.map(&:team).uniq
  end

  def swap_teams
    if teams.size == 2
      transaction do
        game_details.each do |detail|
          new_team = (teams - [detail.team]).first
          detail.update_attribute(:team, new_team)
        end
      end
    else
      errors.add(:base, "Only games with exactly 2 teams can be swapped.")
      false
    end

  end
end
