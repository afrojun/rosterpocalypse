require 'rails_helper'

RSpec.describe GameweekPlayer, type: :model do
  let(:player) { FactoryBot.create :player }
  let(:game) { FactoryBot.create :game }
  let(:gameweek) { FactoryBot.create :gameweek }
  let(:detail) { FactoryBot.create :game_detail, player: player, game: game }

  context '#calculate_bonus_points' do
    # TODO
  end
end
