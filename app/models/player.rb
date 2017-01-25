class Player < ApplicationRecord
  extend FriendlyId
  friendly_id :name

  has_many :game_details
  has_many :games, -> { order "start_date DESC" }, through: :game_details
  has_many :heroes, through: :game_details
  has_many :alternate_names, class_name: "PlayerAlternateName", dependent: :destroy
  belongs_to :team
  has_and_belongs_to_many :rosters
  has_many :gameweek_rosters, through: :rosters
  has_many :gameweek_players, dependent: :destroy
  has_many :gameweeks, through: :gameweek_players
  has_many :transfers_in, dependent: :destroy, class_name: "Transfer", foreign_key: "player_in_id"
  has_many :transfers_out, dependent: :destroy, class_name: "Transfer", foreign_key: "player_out_id"

  validates :name, presence: true, uniqueness: true

  after_create :update_alternate_names
  after_update :update_alternate_names
  before_destroy :validate_destroy

  ROLES = %w{ Support Warrior Assassin Flex }
  FLEX_CLASSIFICATIONS = %w{ Specialist Multiclass Flex }

  # This is the maximum and minimum values that a player can have to
  # ensure that the best players don't become overly expensive and
  # all players have some value
  MIN_VALUE = 50.0
  MAX_VALUE = 200.0
  INITIAL_VALUE = 100.0

  def update_alternate_names
    PlayerAlternateName.find_or_create_by(player: self, alternate_name: name)
    PlayerAlternateName.find_or_create_by(player: self, alternate_name: name.downcase)
    PlayerAlternateName.find_or_create_by(player: self, alternate_name: slug)
  end

  def validate_destroy
    roster_count = rosters.count
    game_count = game_details.count
    if game_count > 0
      errors.add(:base, "Unable to delete #{name} since it has #{game_count} associated #{"game".pluralize(game_count)}.")
      throw :abort
    end

    if roster_count > 0
      errors.add(:base, "Unable to delete #{name} since it has #{roster_count} associated #{"roster".pluralize(roster_count)}.")
      throw :abort
    end
  end

  # Accepts either a string or Array of names as input
  def self.find_including_alternate_names player_names
    player_names = [player_names] if player_names.is_a?(String)
    downcase_names = player_names.map(&:downcase).uniq
    alternate_names = PlayerAlternateName.where(alternate_name: downcase_names).includes(:player)
    alternate_names.map(&:player).uniq
  end

  def self.find_or_create_including_alternate_names player_name
    alternate_names = PlayerAlternateName.where alternate_name: player_name.downcase
    if alternate_names.any?
      alternate_names.first.player
    else
      Player.find_or_create_by name: player_name
    end
  end

  def self.players_in_role roles
    Player.where(role: roles)
  end

  def self.role_stat_percentile roles, stat, percentile
    details = GameDetail.where(player: players_in_role(roles)).extend(DescriptiveStatistics)
    details.percentile(percentile) do |detail|
      detail.send stat.to_sym
    end
  end

  def self.merge_players players
    if players.size > 1
      player_names = []

      # We choose the primary player to be the one with the most recent game
      players.sort_by! do |player|
        player.games.first.try :start_date
      end
      primary = players.shift

      players.each do |player|
        player_name = player.name
        primary.merge! player
        player_names << player_name
      end
      [true, "Merge successful! Merged #{player_names.to_sentence} with #{primary.name}."]
    else
      [false, "Please choose more than 1 player to merge."]
    end
  end

  # Perform a destructive merge with another player
  def merge! other_player
    transaction do
      # Save the alternate names to add them to this player once the other player is destroyed
      other_player_alternate_names = other_player.alternate_names.map(&:alternate_name)

      # Update the team if it is currently Unknown
      if team.name == "Unknown" && other_player.team.name != "Unknown"
        update_attribute(:team, other_player.team)
      end

      # Change all game details for the merged player to point to this player
      other_player.game_details.each do |detail|
        detail.update_attribute :player, self
      end

      # Reload to pick up the newly associated game details
      reload

      # After updating game details, update all associated gameweek players
      # If we already have a gameweek_player covering this gameweek, we need to refresh all game data
      # Otherwise, since there is no existing gameweek_player, simply update the player
      other_player.gameweek_players.each do |other_gameweek_player|
        gameweek = other_gameweek_player.gameweek
        if gameweeks.include? gameweek
          gameweek_player = gameweek_players.where(gameweek: gameweek).first
          gameweek_player.update_all_games
        else
          other_gameweek_player.update_attribute :player, self
        end
      end

      # Replace the merged player in any existing rosters with this player
      other_player.rosters.each do |roster|
        roster.players.delete(other_player)
        roster.players << self
      end

      # Update transfers
      other_player.transfers_in.each do |transfer|
        transfer.update_attribute :player_in, self
      end
      other_player.transfers_out.each do |transfer|
        transfer.update_attribute :player_out, self
      end

      # Destroy the old player
      other_player.reload
      other_player.destroy

      # Finally add the merged player's alternate names to the primary
      other_player_alternate_names.each do |alt_name|
        PlayerAlternateName.find_or_create_by(player: self, alternate_name: alt_name)
      end
    end
  end

  def update_value
    player_value = game_details.includes(:game).reduce(INITIAL_VALUE) do |tracking_value, details|
                    tracking_value + value_change(details)
                  end

    inflation_adjustment_factor = -10
    player_value = player_value.round(2) + inflation_adjustment_factor

    if player_value <= MAX_VALUE and player_value >= MIN_VALUE
      update_attribute :value, player_value
    elsif player_value > MAX_VALUE
      update_attribute :value, MAX_VALUE
    elsif player_value < MIN_VALUE
      update_attribute :value, MIN_VALUE
    end
  end

  def infer_role
    if player_heroes_by_classification.size > 1
      class_ratios = player_heroes_by_classification.reduce({}) do |class_counts, (classification, heroes)|
                       class_counts.merge({ classification => heroes.count.to_f/game_details.count })
                     end
      majority_class = class_ratios.detect { |_, ratio| ratio > 0.5 }
      set_role_from_class(majority_class.present? ? majority_class.first : "Flex")
    else
      set_role_from_class player_heroes_by_classification.keys.first
    end
  end

  def set_role_from_class classification
    player_role = is_flex?(classification) ? "Flex" : classification
    update_attribute :role, player_role
  end

  private

  def player_heroes_by_classification
    @player_heroes_by_classification ||= game_details.map(&:hero).group_by(&:classification)
  end

  def is_flex? classification
    FLEX_CLASSIFICATIONS.include? classification
  end

  # Value breakdown:
  # Kill         = +0.1
  # Assist       = +0.02
  # Win          = +0.5
  # Loss         = -0.5
  # 15s Dead     = -0.05
  # scaling factor = +/-0.05 * diff in ave team value
  def value_change details
    game = details.game
    opposing_players = game.game_details.includes(:player).where('team_id != ?', details.team_id).map(&:player)
    ave_opponent_value = opposing_players.sum(&:value)/opposing_players.size.to_f

    team_players = game.game_details.includes(:player).where('team_id = ?', details.team_id).map(&:player)
    ave_team_value = team_players.sum(&:value)/team_players.size.to_f

    # This scales the win multiplier based on the relative strength of the two teams
    scaling_factor_string = "((#{ave_opponent_value} - #{ave_team_value}) * #{details.win_int_neg.to_f} * 0.05"
    scaling_factor = (ave_opponent_value - ave_team_value) * details.win_int_neg.to_f * 0.05
    Rails.logger.debug "scaling_factor calculation: #{scaling_factor_string} = #{scaling_factor}"

    calculation_string = "(#{details.solo_kills.to_f} * 0.1) + (#{details.assists.to_f} * 0.02) + (#{details.win_int_neg.to_f} * (0.5 + #{scaling_factor})) - ((#{details.time_spent_dead.to_f}/15) * 0.05)"
    result = (details.solo_kills.to_f * 0.1) + (details.assists.to_f * 0.02) + (details.win_int_neg.to_f * (0.5 + scaling_factor)) - ((details.time_spent_dead.to_f/15) * 0.05)
    Rails.logger.debug "value_change calculation: #{calculation_string} = #{result}"
    result
  end
end
