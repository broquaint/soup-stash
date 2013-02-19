module GamesHelper
  def morgue_uri(game)
    host = URI.parse(game.server).host
    file = 'morgue-%s-%s.txt' % [game.character, game.end_time_str]
    URI.parse( DCSS::MORGUE_PATHS[host].call(game) + "#{game.character}/#{file}" )
  end

  def morgue_link(game)
    uri = morgue_uri(game)
    # TODO - Abbreviate host.
    link_to uri.host, uri.to_s, title: uri.to_s
  end
end
