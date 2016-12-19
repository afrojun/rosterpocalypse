class Player < ApplicationRecord
  extend FriendlyId
  friendly_id :name

  has_many :player_game_details
  has_many :games, through: :player_game_details
  has_many :heroes, through: :player_game_details
  has_many :alternate_names, class_name: "PlayerAlternateName", dependent: :destroy
  belongs_to :team
  has_and_belongs_to_many :rosters

  validates :name, presence: true, uniqueness: true

  after_create :update_alternate_names
  after_update :update_alternate_names
  before_destroy :validate_destroy

  ROLES = %w{ Support Warrior Assassin Flex }
  FLEX_CLASSIFICATIONS = %w{ Specialist Multiclass Flex }

  # This is the maximum and minimum costs that a player can have to
  # ensure that the best players don't become overly expensive and
  # all players have some value
  MIN_COST = 50
  MAX_COST = 200
  INITIAL_COST = 100

  def update_alternate_names
    PlayerAlternateName.find_or_create_by(player: self, alternate_name: name)
  end

  def validate_destroy
    gameCount = PlayerGameDetail.where(player: self).count
    if gameCount > 0
      errors.add(:base, "Unable to delete #{name} since it has #{gameCount} associated #{"game".pluralize(gameCount)}.")
      throw :abort
    end
  end

  def self.find_or_create_including_alternate_names player_name
    alternate_names = PlayerAlternateName.where alternate_name: player_name
    if alternate_names.any?
      alternate_names.first.player
    else
      Player.find_or_create_by name: player_name
    end
  end

  def update_cost
    player_cost = player_game_details.reduce(INITIAL_COST) do |tracking_cost, details|
                    tracking_cost + cost_change(details)
                  end

    if player_cost <= MAX_COST and player_cost >= MIN_COST
      update_attribute :cost, player_cost
    elsif player_cost > MAX_COST
      update_attribute :cost, MAX_COST
    elsif player_cost < MIN_COST
      update_attribute :cost, MIN_COST
    end
  end

  def infer_role
    if player_heroes_by_classification.size > 1
      class_ratios = player_heroes_by_classification.reduce({}) do |class_counts, (classification, heroes)|
                       class_counts.merge({ classification => heroes.count.to_f/player_game_details.count })
                     end
      majority_class = class_ratios.detect do |_, ratio|
        ratio > 0.5
      end
      if majority_class.present?
        set_role_from_class majority_class.first
      else
        set_role_from_class "Flex"
      end

    else
      set_role_from_class player_heroes_by_classification.keys.first
    end
  end

  private

  def set_role_from_class classification
    player_role = is_flex?(classification) ? "Flex" : classification
    update_attribute :role, player_role
  end

  def player_heroes_by_classification
    @player_heroes_by_classification ||= player_game_details.map(&:hero).group_by(&:classification)
  end

  def is_flex? classification
    FLEX_CLASSIFICATIONS.include? classification
  end

  # Cost breakdown:
  # Kill         = +0.5
  # Assist       = +0.25
  # Win          = +1
  # Loss         = -1
  # 15s Dead     = -0.5
  def cost_change details
    ((details.solo_kills.to_f * 0.5) + (details.assists.to_f * 0.25) + (win_int(details) * 2) - ((details.time_spent_dead.to_f/15) * 0.5)).ceil
  end

  def win_int details
    details.win ? 1 : -1
  end

end
