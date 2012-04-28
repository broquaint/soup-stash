class Player
  include Mongoid::Document
  field :game, :type => String
  field :name, :type => String
  embedded_in :user
end
