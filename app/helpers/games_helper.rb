module GamesHelper
  def morgue_link(game)
    file = 'morgue-%s-%s.txt' % [game.character, game.end_time_str]
    path = ['morgue', game.character, file].join '/'
    uri = URI::HTTP.build(host: 'dobrazupa.org', path: "/#{path}")
    link_to "Link to morgue on #{game.server}", uri.to_s
  end
end
