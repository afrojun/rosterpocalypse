class Match < ApplicationRecord
  include ActiveModel::Validations

  belongs_to :team_1, class_name: "Team"
  belongs_to :team_2, class_name: "Team"
  belongs_to :gameweek
  belongs_to :stage
  has_many :games, -> { order "start_date" }

  validate :start_date_in_gameweek

  def start_date_in_gameweek
    errors.add(:Match, 'start date must be within the associated gameweek') unless start_date >= gameweek.start_date && start_date <= gameweek.end_date
  end

  def teams
    [team_1, team_2]
  end

  def description
    teams.map(&:name).join(" vs. ")
  end

  def short_description
    teams.map(&:short_name).join(" vs. ")
  end

  def score
    team_1_wins = 0
    team_2_wins = 0
    games.each do |game|
      winner = game.winner
      team_1_wins = (team_1_wins + 1) if winner == team_1
      team_2_wins = (team_2_wins + 1) if winner == team_2
    end

    [team_1_wins, team_2_wins]
  end
end
