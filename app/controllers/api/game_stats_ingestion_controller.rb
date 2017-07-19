module Api
  class GameStatsIngestionController < Api::BaseApiController
    # before_action :authenticate_user!

    # POST /replay_details
    def create
      response = JSON.parse params["response"]
      GameStatsIngestionService.new(response).populate_from_json
    end
  end
end
