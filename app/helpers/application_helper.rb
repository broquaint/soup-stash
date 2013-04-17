module ApplicationHelper
  def combo_abbr(game)
    DCSS.combo2abbr(game.race, game.background)
  end

  def player_link(game)
    link_to game.character, user_player_path(game.player.user, game.player)
  end

  # Like link_to but adds parameters to existing set.
  def link_to_with(text, with_params, options = {})
    # Bleh relies on global state i.e params. Also use to_hash to get
    # intended merge functionality i.e do stuff on dupes.
    new_params = params.to_hash.merge(with_params) do |key, oldval, newval|
      if options[:no_merge]
        newval
      else
        (oldval.is_a?(Array) ? oldval + [newval] : [oldval, newval]).uniq
      end
    end
    link_to text, new_params, options[:html] || {}
  end

  def combo_link(game, text = nil)
    link_to text || "#{game.race} #{game.background}",
            games_path(race: game.race, background: game.background)
  end
end
