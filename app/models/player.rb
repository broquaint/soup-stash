class Player
  include Mongoid::Document
  field :for_game, :type => String # Possibly unnecessary/implied?
  field :name,     :type => String
  belongs_to  :user
  has_many    :games
end
