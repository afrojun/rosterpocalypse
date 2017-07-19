require 'rails_helper'

RSpec.describe 'Gameweeks', type: :request do
  describe 'GET /gameweeks' do
    it 'works! (now write some real specs)' do
      get gameweeks_path
      expect(response).to have_http_status(200)
    end
  end
end
