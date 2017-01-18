class Match < ApplicationRecord
  belongs_to :team_1, class_name: "Team"
  belongs_to :team_2, class_name: "Team"
  belongs_to :gameweek
  has_many :games, -> { order "start_date" }

  def teams
    [team_1, team_2]
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
