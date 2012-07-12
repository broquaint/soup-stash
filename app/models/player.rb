class Player
  include Mongoid::Document

  paginates_per 27
  
  field :for_game, :type => String # Possibly unnecessary/implied?
  field :name,     :type => String

  # Cumulative fields
  field :played, :type => Integer,     :default => -> { 0 }
  field :kills,  :type => Integer,     :default => -> { 0 }
  field :time_spent, :type => Integer, :default => -> { 0 }
  field :levels_seen, :type => Integer, :default => -> { 0 }
  field :nemesis, :type => String

  field :favourites, :type => Hash, :default => { :race => {}, :background => {}, :god => {} }
 
  field :created_at, :type => Time, :default => -> { Time.now }
  
  belongs_to  :user
  has_many    :games
  field :_id, :type => String, :default => -> { "%s-%s" % [name, for_game] }
end
