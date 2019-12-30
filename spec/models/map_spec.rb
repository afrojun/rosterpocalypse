require 'rails_helper'

RSpec.describe Map, type: :model do
  context '#destroy' do
    let(:map) { FactoryBot.create :map }

    it 'succeeds if there are no associated games' do
      id = map.id
      map.destroy
      expect(Map.where(id: id)).to be_blank
    end

    it 'fails if there are any associated games' do
      FactoryBot.create :game, map: map
      id = map.id
      map.destroy
      expect(Map.where(id: id).first).to eq map
      expect(map.errors.details[:base].first[:error]).to include("Unable to delete #{map.name}")
    end
  end
end
