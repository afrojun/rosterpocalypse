module PlayerHelper

  def link_to_heroes heroes
    heroes.collect do |hero|
      link_to hero.name, hero
    end.to_sentence(two_words_connector: ", ", last_word_connector: ", ").html_safe
  end

  def link_to_heroes_with_stat heroes_with_stat
    heroes_with_stat.collect do |hero, stat|
      link_to "#{hero.name} (#{stat})", hero
    end.to_sentence(two_words_connector: ", ", last_word_connector: ", ").html_safe
  end

  def player_role_icon player, size = 24
    role_icon player.role, size
  end

  def role_icon role, size = 24
    absolute_image_tag "#{role.downcase}_icon.png", alt: role, size: size
  end
end