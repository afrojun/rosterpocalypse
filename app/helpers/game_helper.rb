module GameHelper
  def teams_with_bold_winner(teams_by_win)
    winner = embolden(teams_by_win[true])
    loser = teams_by_win[false]
    [winner, loser].join(" vs. ").html_safe
  end

  def embolden(text)
    "<b>#{text}</b>"
  end
end
