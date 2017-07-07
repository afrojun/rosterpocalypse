class Match < ApplicationRecord
  include ActiveModel::Validations

  belongs_to :team_1, class_name: "Team"
  belongs_to :team_2, class_name: "Team"
  belongs_to :gameweek
  has_one :tournament, through: :gameweek
  belongs_to :stage
  has_many :games, -> { order "start_date" }

  validate :start_date_in_gameweek

  before_destroy :disassociate_games

  MATCH_SCORE_TO_BEST_OF = {
    [0, 0] => 1,
    [0, 1] => 1,

    [1, 1] => 3,
    [0, 2] => 3,
    [1, 2] => 3,

    [2, 2] => 5,
    [0, 3] => 5,
    [1, 3] => 5,
    [2, 3] => 5,

    [3, 3] => 7,
    [0, 4] => 7,
    [1, 4] => 7,
    [2, 4] => 7,
    [3, 4] => 7,

    [4, 4] => 9,
    [0, 5] => 9,
    [1, 5] => 9,
    [2, 5] => 9,
    [3, 5] => 9,
    [4, 5] => 9
  }

  # Add a game to an existing match if one exists, otherwise create a Match for the game
  def self.add_game game
    game_team_ids = game.teams.map(&:id)
    # Get a set of candidate matches that this game could be a part of.
    # We filter for matches which are within 4 hours of the game start_date
    team_matches = Match.where("team_1_id in (?) AND team_2_id in (?)", game_team_ids, game_team_ids)
    candidate_matches = team_matches.to_a.select do |match|
                          if match.games.any?
                            (match.games.last.start_date - game.start_date).abs < 4.hours
                          else
                            (match.start_date - game.start_date).abs < 5.hours
                          end
                        end

    if candidate_matches.size == 0
      Rails.logger.info "Creating a new Match..."
      match = Match.new(
        team_1: game.teams.first,
        team_2: game.teams.last,
        gameweek: game.gameweek,
        start_date: game.start_date,
        best_of: 1
      )
      match.save
      game.update(match: match)

    elsif candidate_matches.size == 1
      Rails.logger.info "Updating an existing Match..."
      match = candidate_matches.first
      game.update(match: match)
      match.reload
      score = match.score.values.sort
      Rails.logger.info "score: #{score}"

      match.update(
        start_date: ((match.start_date < game.start_date) ? match.start_date : game.start_date),
        best_of: MATCH_SCORE_TO_BEST_OF[score]
      )

    elsif candidate_matches.size > 1
      Rails.logger.error "More than 1 possible Match found! Unable to add game '#{game.game_hash}' to a match."
      false
    end
  end

  def disassociate_games
    games.each { |game| game.update! match: nil }
  end

  def start_date_in_gameweek
    errors.add(:Match, 'start date must be within the associated gameweek') unless start_date >= gameweek.start_date && start_date <= gameweek.end_date
  end

  def teams
    [team_1, team_2]
  end

  def description
    score.map { |team, score| "#{team.name} (#{score})" }.join(" vs. ")
  end

  def short_description
    teams.map(&:short_name).join(" vs. ")
  end

  def score
    team_1_wins = 0
    team_2_wins = 0
    game_winners = games.includes(:game_details).map(&:winner)

    Hash[team_1, game_winners.count(team_1),
         team_2, game_winners.count(team_2)]
  end
end
