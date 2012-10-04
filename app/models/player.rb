require 'soupstash/model/player'

# Slightly gross but inheritence isn't quite what we want.
Player = SoupStash::Model::Player
class Player
  paginates_per 27
  belongs_to  :user  
end
