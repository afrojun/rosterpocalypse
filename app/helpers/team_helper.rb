module TeamHelper

  def link_to_team_with_logo team, size = 24
    link_to team do
      team_logo team
    end
  end

  def team_logo team, size = 24
    absolute_image_tag team_logo_filename(team), alt: team.name, size: size
  end

  def team_logo_filename team
    team.name.start_with?("Team") ? "#{team.slug.underscore}_logo.png" : "team_#{team.slug.underscore}_logo.png"
  end

end