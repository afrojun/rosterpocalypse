class GameweeksController < RosterpocalypseController
  before_action :set_gameweek, only: [:show]
  before_action :set_tournament
  before_action :set_page_title, only: [:show, :edit]

  # GET /gameweeks
  # GET /gameweeks.json
  def index
    @gameweeks = @tournament.gameweeks
  end

  # GET /gameweeks/1
  # GET /gameweeks/1.json
  def show
    @roster = Roster.find_by_manager_and_tournament current_user.manager, @tournament
    @gameweek_players = @gameweek.gameweek_players.includes(:player, :team, :gameweek_rosters).order(points: :desc).all
    valid_gameweek_rosters = @gameweek.gameweek_rosters.includes(transfers: [:player_in, :player_out]).where("points IS NOT NULL")
    valid_gameweek_rosters_count = valid_gameweek_rosters.size
    max_points = @gameweek_players.first.try :points
    min_value = @gameweek.players.order(:value).first.try :value
    efficiency_factor = (max_points && min_value) ? max_points/min_value : 1
    logger.info "Player Efficiency factor = max_points/min_value = #{max_points}/#{min_value} = #{efficiency_factor}"

    @gameweek_players_stats = Hash[
      @gameweek_players.map do |gameweek_player|
        [
          gameweek_player,
          {
            pick_rate: ((gameweek_player.gameweek_rosters.size.to_f/valid_gameweek_rosters_count.to_f)*100).round(2),
            efficiency: (((gameweek_player.points/gameweek_player.value)/efficiency_factor)*100).round(2)
          }
        ]
      end
    ]

    gameweek_players_sorted_by_efficiency = @gameweek_players_stats.sort { |(_, a), (_, b)| a[:efficiency] <=> b[:efficiency] }.map(&:first).reverse
    @dream_team_gameweek_players = Set.new
    @dream_team_gameweek_players << gameweek_players_sorted_by_efficiency.detect { |gameweek_player| gameweek_player.player.role == "Warrior" }
    @dream_team_gameweek_players << gameweek_players_sorted_by_efficiency.detect { |gameweek_player| gameweek_player.player.role == "Support" }
    index = 0
    while gameweek_players_sorted_by_efficiency[index].present? && @dream_team_gameweek_players.size < Roster::MAX_PLAYERS
      @dream_team_gameweek_players << gameweek_players_sorted_by_efficiency[index]
      index = index + 1
    end

    @transfers_in = @gameweek.transfers.select("player_in_id, count(player_in_id)").group(:player_in_id).size.sort  { |(_, a), (_, b)| a <=> b }.last(5).reverse
    @transfers_out = @gameweek.transfers.select("player_out_id, count(player_out_id)").group(:player_out_id).size.sort  { |(_, a), (_, b)| a <=> b }.last(5).reverse
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_gameweek
      @gameweek = Gameweek.find(params[:id])
    end

    def set_tournament
      @tournament = @gameweek.try(:tournament) || Tournament.find(params[:tournament_id])
    end

    def set_page_title
      @page_title = "#{@tournament.name}: #{@gameweek.name}"
    end
end
