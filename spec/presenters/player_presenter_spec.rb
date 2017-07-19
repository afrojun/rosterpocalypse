require 'rails_helper'

RSpec.describe PlayerPresenter do
  let(:player) { FactoryGirl.create :player }
  let(:presenter) { PlayerPresenter.new player, nil }

  let(:hero1) { FactoryGirl.create :hero, name: 'hero1' }
  let(:hero2) { FactoryGirl.create :hero, name: 'hero2' }
  let(:hero3) { FactoryGirl.create :hero, name: 'hero3' }
  let(:hero4) { FactoryGirl.create :hero, name: 'hero4' }
  let(:hero5) { FactoryGirl.create :hero, name: 'hero5' }

  let(:hero_stats) do
    {
      hero1 => { win: 1, loss: 3, total: 4 },
      hero2 => { win: 3, loss: 2, total: 5 },
      hero3 => { win: 6, loss: 3, total: 9 },
      hero4 => { win: 4, loss: 3, total: 7 },
      hero5 => { win: 2, loss: 1, total: 3 }
    }
  end

  context '#player_hero_win_loss_count' do
    it 'returns an empty hash for players with no games' do
      expect(presenter.player_hero_win_loss_count).to eq({})
    end

    it 'correctly populates the win/loss/total counts' do
      FactoryGirl.create :game_detail, player: player, hero: hero1, win: true
      FactoryGirl.create :game_detail, player: player, hero: hero1, win: false
      FactoryGirl.create :game_detail, player: player, hero: hero2, win: true
      FactoryGirl.create :game_detail, player: player, hero: hero3, win: false
      expect(presenter.player_hero_win_loss_count[hero1]).to eq(win: 1, loss: 1, total: 2)
      expect(presenter.player_hero_win_loss_count[hero2]).to eq(win: 1, loss: 0, total: 1)
      expect(presenter.player_hero_win_loss_count[hero3]).to eq(win: 0, loss: 1, total: 1)
    end
  end

  context '#most_played_heroes' do
    it 'returns the most played heroes' do
      expect(presenter).to receive(:player_hero_win_loss_count).and_return(hero_stats)
      expect(presenter.most_played_heroes).to eq [[hero3, 9], [hero4, 7], [hero2, 5]]
    end
  end

  context '#top_winrate_heroes' do
    it 'returns the highest winrate heroes' do
      expect(presenter).to receive(:player_hero_win_loss_count).and_return(hero_stats)
      expect(presenter.top_winrate_heroes).to eq [[hero5, 67], [hero3, 67], [hero2, 60]]
    end
  end
end
