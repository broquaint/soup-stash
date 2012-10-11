module GamesHelper
  def morgue_uri(game)
    file = 'morgue-%s-%s.txt' % [game.character, game.end_time_str]
    path = ['morgue', game.character, file].join '/'
    URI::HTTP.build(host: 'dobrazupa.org', path: "/#{path}")
  end

  def morgue_link(game)
    uri = morgue_uri(game)
    link_to 'cszo', uri.to_s, title: uri.to_s
  end
  def update_morgue_link(game)
    file = 'morgue-%s-%s.txt' % [game.character, game.end_time_str]
    path = ['morgue', game.character, file].join '/'
    uri = URI::HTTP.build(host: 'dobrazupa.org', path: "/#{path}")
    link_to "#{uri.to_s}", game_path(game), id: 'morgue-link', method: :put
  end
end
