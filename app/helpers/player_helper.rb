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

end