class Game # Specifically DCSS
  include Mongoid::Document
  field :game, :type => String
  # via https://github.com/greensnark/dcss_scoring/blob/master/databasedesign.txt
  field :start_time, :type => String
  field :score, :type => Integer
  field :race, :type => String
  field :background, :type => String
  field :version, :type => String
  field :lv, :type => String
  field :character, :type => String
  field :xl, :type => Integer
  field :skill, :type => String
  field :sk_lev, :type => String
  field :title, :type => String
  field :place, :type => String
  field :branch, :type => String
  field :lvl, :type => String
  field :ltyp, :type => String
  field :hp, :type => Integer
  field :maxhp, :type => Integer
  field :maxmaxhp, :type => Integer
  field :str, :type => Integer
  field :int, :type => Integer
  field :dex, :type => Integer
  field :god, :type => String
  field :duration, :type => String
  field :turn, :type => Float
  field :runes, :type => Integer
  field :killertype, :type => String
  field :killer, :type => String
  field :damage, :type => Integer
  field :piety, :type => Integer
  field :end_time, :type => String
  belongs_to :user
end
