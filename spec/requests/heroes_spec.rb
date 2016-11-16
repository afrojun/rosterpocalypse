require 'rails_helper'

RSpec.describe "Heroes", type: :request do
  describe "GET /heroes" do
    it "works! (now write some real specs)" do
      get heroes_path
      expect(response).to have_http_status(200)
    end
  end
end
