require 'soupstash/model/game'

# Slightly gross but inheritence isn't quite what we want.
Game = SoupStash::Model::Game
class Game
  # Kaminara paging dealy.
  paginates_per 27  
end
