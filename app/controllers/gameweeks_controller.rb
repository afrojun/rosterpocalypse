class GameweeksController < RosterpocalypseController
  before_action :set_gameweek, only: [:show]
  before_action :set_tournament, only: [:show]
  before_action :set_page_title, only: [:show]

  # GET /gameweeks
  # GET /gameweeks.json
  def index
    @tournaments = Tournament.active_tournaments
  end

  # GET /gameweeks/1
  # GET /gameweeks/1.json
  def show
    @gameweek_statistics = GameweekStatistic.find_or_initialize_by(gameweek: @gameweek)
    @league_gameweek_players = @gameweek.default_league.league_gameweek_players.
                                 joins(:gameweek_player).
                                 where("gameweek_players.gameweek_id = ?", @gameweek.id).
                                 includes(:gameweek_player).
                                 order(points: :desc)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_gameweek
    @gameweek = Gameweek.find(params[:id])
  end

  def set_tournament
    @tournament = @gameweek.tournament
  end

  def set_page_title
    @page_title = "#{@tournament.name}: #{@gameweek.name}"
  end
end
