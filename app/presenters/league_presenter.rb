class LeaguePresenter < BasePresenter
  MAX_DESCRIPTION_LENGTH = 40

  def truncated_description
    if league.description.length > MAX_DESCRIPTION_LENGTH
      league.description[0..(MAX_DESCRIPTION_LENGTH - 3)] + "..."
    else
      league.description
    end
  end

  alias league __getobj__
end
