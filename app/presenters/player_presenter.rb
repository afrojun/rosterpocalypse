class PlayerPresenter < BasePresenter
  def most_played_heroes
    top_three = player_hero_win_loss_count.sort_by do |hero, stats|
      stats[:total]
    end.reverse.take(3)

    top_three.map do |hero, stats|
      [hero, stats[:total]]
    end
  end

  def top_winrate_heroes
    top_three = player_hero_win_loss_count.sort_by do |hero, stats|
      ((stats[:win].to_f / stats[:total].to_f) * 100).ceil.tap do |win_percent|
        stats[:win_percent] = win_percent
      end
    end.reverse.take(3)

    top_three.map do |hero, stats|
      [hero, stats[:win_percent]]
    end
  end

  def player_hero_win_loss_count
    @player_hero_win_loss_count ||= {}.tap do |hero_details|
      player.game_details.includes(:hero).each do |details|
        if win_loss = hero_details[details.hero]
          win_loss[:total] = win_loss[:total] + 1
          if details.win
            win_loss[:win] = win_loss[:win] + 1
          else
            win_loss[:loss] = win_loss[:loss] + 1
          end
        else
          hero_details[details.hero] = {
            win: details.win ? 1 : 0,
            loss: details.win ? 0 : 1,
            total: 1
          }
        end
      end
    end
  end

  alias player __getobj__
end
