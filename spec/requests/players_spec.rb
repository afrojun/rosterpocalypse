require 'rails_helper'
require 'requests/shared_restricted_index_page_request_spec'

RSpec.describe 'Players', type: :request do
  describe 'GET /players' do
    it 'works! (now write some real specs)' do
      get players_path
      expect(response).to have_http_status(200)
    end
  end
end
