module LeagueHelper
  def league_membership_change(league, button_size_class)
    if user_signed_in?
      roster = Roster.find_by manager: current_user.manager, league: league
      if league.rosters.include? roster
        link_to_leave_league league, button_size_class
      else
        link_to_join_league league, button_size_class
      end
    end
  end

  def link_to_join_league(league, button_size_class)
    link_to_manage_league_membership league, :join, button_size_class
  end

  def link_to_leave_league(league, button_size_class)
    link_to_manage_league_membership league, :leave, button_size_class
  end

  def link_to_manage_league_membership(league, action, button_size_class)
    join_path = "#{action}_#{league.class.to_s.underscore}_path"
    button_colour_class = action.to_sym == :join ? "btn-info" : "btn-danger"
    link_to action.to_s.titleize,
            send(join_path.to_sym, league),
            method: :post,
            class: "btn #{button_colour_class} #{button_size_class}"
  end
end