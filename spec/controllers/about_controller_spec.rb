require 'rails_helper'

RSpec.describe AboutController, type: :controller do
  describe 'GET #about' do
    it 'returns http success' do
      get :about
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #credits' do
    it 'returns http success' do
      get :credits
      expect(response).to have_http_status(:success)
    end
  end
end
