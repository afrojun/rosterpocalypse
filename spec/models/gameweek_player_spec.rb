require 'rails_helper'

RSpec.describe GameweekPlayer, type: :model do
  let(:player) { FactoryGirl.create :player }
  let(:game) { FactoryGirl.create :game }
  let(:gameweek) { FactoryGirl.create :gameweek }
  let(:detail) { FactoryGirl.create :game_detail, player: player, game: game }

  context "#calculate_bonus_points" do
    #TODO
  end
end
