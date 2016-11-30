class PlayerGameDetail < ApplicationRecord
  belongs_to :player
  belongs_to :game
  belongs_to :hero
  # Other attributes
  # solo_kills, assists, deaths, time_spent_dead, team_colour, win

  after_create :update_player_cost
  after_update :update_player_cost
  before_save :revert_player_cost

  attr_reader :previous_cost_change

  def revert_player_cost
    player.update_attribute :cost, player.cost - previous_cost_change
  end

  def update_player_cost
    updated_cost = player.cost + cost_change
    if updated_cost <= Player::MAX_COST and updated_cost >= Player::MIN_COST
      player.update_attribute(:cost, updated_cost)
      @previous_cost_change = cost_change
    end
  end

  # Cost breakdown:
  # Kill         = +1
  # Assist       = +1
  # Win          = +2
  # 30s Dead     = -1
  def cost_change
    solo_kills + assists + (win_int * 2) - (time_spent_dead/30)
  end

  def win_int
    win ? 1 : 0
  end

  def previous_cost_change
    @previous_cost_change ||= 0
  end

end
