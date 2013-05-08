# -*- coding: utf-8 -*-
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

  def server_link(game)
    uri = URI.parse(game.server)
    link_to DCSS::HOST_TO_ABBR[uri.host], uri.to_s, title: uri.host
  end

  def nice_duration(game)
    match = game.duration.match /(?:(?<d>\d+)\s+)?(?<h>\d+):(?<m>\d+):(?<s>\d+)/
    
    total_time = if match
                   (( match[:d].to_i || 0 ) * 86000) +
                   (( match[:h].to_i || 0 ) * 3600)  +
                   (( match[:m].to_i || 0 ) * 60 )   +
                   match[:s].to_i
                 else
                   game.duration.to_i
                 end
    
    humanize total_time
  end

  # Thanks to Mladen JablanoviÄfor this via http://stackoverflow.com/a/4136485
  def humanize(secs)
    [[60, :seconds], [60, :minutes], [24, :hours], [1000, :days]].map{ |count, name|
      if secs > 0
        secs, n = secs.divmod(count)
        "#{n.to_i} #{name}"
      end
    }.compact.reverse.join(', ')
  end
end
