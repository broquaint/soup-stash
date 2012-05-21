module FrontPageHelper
  # XXX Should probably move both to the app helper.
  def combo_abbr(game)
    Coroner::CrawlCombos.combo2abbr(game.race, game.background)
  end
  def player(game)
    link_to game.character, user_player_path(game.player.user, game.player)
  end
end
