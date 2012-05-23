class Player
  include Mongoid::Document
  field :for_game, :type => String # Possibly unnecessary/implied?
  field :name,     :type => String

  # Cumulative fields
  field :played, :type => Integer,     :default => -> { 0 }
  field :kills,  :type => Integer,     :default => -> { 0 }
  field :time_spent, :type => Integer, :default => -> { 0 }
  field :levels_seen, :type => Integer, :default => -> { 0 }
  field :nemesis, :type => String

  field :favourites # An object of things, don't want to decide yet what they'll be

  
  belongs_to  :user
  has_many    :games
  key :name, :for_game
end
