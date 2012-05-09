class Game # Specifically DCSS
  include Mongoid::Document
  
  field :game, :type => String
  # XXX All of it?
  field :morgue, :type => String
  
  # via https://github.com/greensnark/dcss_scoring/blob/master/databasedesign.txt
  field :start_time , :type => String
  field :score      , :type => Integer # DONE
  field :race       , :type => String  # DONE
  field :background , :type => String  # DONE
  field :version    , :type => String  # DONE
  field :level      , :type => String  # DONE # level == xl, what was lv?
  field :character  , :type => String  # DONE
  field :xl         , :type => Integer # DONE
  field :skill      , :type => String
  field :sk_lev     , :type => String
  field :title      , :type => String  # DONE
  field :place      , :type => String
  field :branch     , :type => String
  field :lvl        , :type => String
  field :ltyp       , :type => String
  field :hp         , :type => Integer
  field :maxhp      , :type => Integer
  field :maxmaxhp   , :type => Integer
  field :str        , :type => Integer
  field :int        , :type => Integer
  field :dex        , :type => Integer
  field :god        , :type => String
  field :duration   , :type => String  # DONE
  field :turn       , :type => Float   # DONE
  field :runes      , :type => Integer
  field :killertype , :type => String
  field :killer     , :type => String
  field :damage     , :type => Integer
  field :piety      , :type => Integer
  field :end_time   , :type => String
  
  belongs_to :user
end
