require 'soupstash/model'

class SoupStash::Model::Player
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in collection: 'players'

  field :for_game, :type => String # Possibly unnecessary/implied?
  field :name,     :type => String

  # Cumulative fields
  field :played,      :type => Integer, :default => -> { 0 }
  field :kills,       :type => Integer, :default => -> { 0 }
  field :time_spent,  :type => Integer, :default => -> { 0 }
  field :levels_seen, :type => Integer, :default => -> { 0 }
  field :nemesis,     :type => String

  field :favourites, :type => Hash, :default => { :race => {}, :background => {}, :god => {} }
 
  has_many :games

  field :_id, :type => String, :default => -> { "%s-%s" % [name, for_game] }

  def update_accumulators(game)
    # XXX Might be simpler to pull these out of a map/reduce as necessary.
    self.played      += 1
    self.kills       += game.kill_total       || 0
    self.time_spent  += game.duration_seconds || 0
    self.levels_seen += game.levels_seen      || 0
    save!
  end
end
