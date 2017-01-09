require 'rails_helper'

RSpec.describe HeroPresenter do
  let(:hero) { FactoryGirl.create :hero }
  let(:presenter) { HeroPresenter.new hero, nil }

  context "#hero_stats" do
    it "calculates the correct win % with no games played" do
      expect(presenter.hero_stats[:win_percent]).to eq 0
    end

    it "calculates the correct win % with 1 game played" do
      FactoryGirl.create :game_detail, hero: hero, win: true
      expect(presenter.hero_stats[:win_percent]).to eq 100
    end

    it "calculates the correct win % with 3 games played" do
      FactoryGirl.create :game_detail, hero: hero, win: true
      FactoryGirl.create :game_detail, hero: hero, win: false
      FactoryGirl.create :game_detail, hero: hero, win: true
      expect(presenter.hero_stats[:win_percent]).to eq 66.67
    end
  end
end
