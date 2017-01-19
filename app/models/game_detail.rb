class GameDetail < ApplicationRecord
  belongs_to :player
  belongs_to :game
  belongs_to :hero
  belongs_to :team

  validates :team_colour, presence: true
  validates :win, inclusion: {in: [true, false]}
  # Other attributes
  # solo_kills, assists, deaths, time_spent_dead, team_colour, win

  def takedowns
    solo_kills + assists
  end

  def win_int
    win ? 1 : 0
  end

  def win_int_neg
    win ? 1 : -1
  end
end
