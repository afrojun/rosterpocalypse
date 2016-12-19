require 'rails_helper'

RSpec.describe Hero, type: :model do
  context "#destroy" do
    let(:hero) { FactoryGirl.create :hero }

    it "succeeds if there are no associated games" do
      id = hero.id
      hero.destroy
      expect(Hero.where(id: id)).to be_blank
    end

    it "fails if there are any associated games" do
      FactoryGirl.create :player_game_detail, hero: hero
      id = hero.id
      hero.destroy
      expect(Hero.where(id: id).first).to eq hero
      expect(hero.errors.details[:base].first[:error]).to include("Unable to delete #{hero.name}")
    end
  end
end
