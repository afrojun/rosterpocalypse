module GameHelper

  def teams_with_bold_winner teams
    teams.collect do |team, details|
      details.first.win ? embolden(team) : team
    end.join(" vs. ").html_safe
  end

  def embolden text
    "<b>#{text}</b>"
  end

end