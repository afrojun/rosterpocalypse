module LeagueHelper

  def league_membership_change league
    roster = Roster.find_by_manager_and_region(current_user.manager, league.tournament.region)
    if league.rosters.include? roster
      link_to_leave_league league
    else
      link_to_join_league league
    end
  end

  def link_to_join_league league
    link_to_manage_league_membership league, :join
  end

  def link_to_leave_league league
    link_to_manage_league_membership league, :leave
  end

  def link_to_manage_league_membership league, action
    join_path = "#{action}_#{league.class.to_s.underscore}_path"
    button_class = action.to_sym == :join ? "btn-info" : "btn-danger"
    link_to "#{action.to_s.titleize}", send(join_path.to_sym, league), method: :post, class: "btn btn-sm #{button_class}"
  end

end