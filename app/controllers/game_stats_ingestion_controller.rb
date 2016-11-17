class GameStatsIngestionController < ApplicationController

  # POST /replay_details
  def create
    response = JSON.parse params["response"]
    GameStatsIngestionService.populate_from_json response
  end
end
