module Api

  class GameStatsIngestionController < Api::BaseApiController
    #before_action :authenticate_user!

    # POST /replay_details
    def create
      response = JSON.parse params["response"]
      GameStatsIngestionService.populate_from_json response
    end
  end

end