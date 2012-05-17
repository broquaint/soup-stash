class Game # Specifically DCSS
  include Mongoid::Document
  
  field :game, :type => String # XXX This is a sucky field name.
  # XXX All of it?
  field :morgue, :type => String

  field :was_local, :type => Boolean # Perhaps should be an enum?
  
  # via https://github.com/greensnark/dcss_scoring/blob/master/databasedesign.txt
  field :start_time , :type => Time    # endtime - duration
  field :score      , :type => Integer # DONE
  field :race       , :type => String  # DONE
  field :background , :type => String  # DONE
  field :version    , :type => String  # DONE
  field :level      , :type => String  # DONE # level == xl, what was lv?
  field :character  , :type => String  # DONE
  field :xl         , :type => Integer # DONE
#  field :skill      , :type => String  # sk=Unarmed Combat
#  field :sk_lev     , :type => String  # sklev=5
  field :title      , :type => String  # DONE
  field :place      , :type => String  # DONE level 7 of the dungeon
  field :branch     , :type => String  # DONE
  field :lvl        , :type => Integer # DONE
  field :ltyp       , :type => String  # == branch ???
  field :hp         , :type => Integer
  field :maxhp      , :type => Integer
  field :maxmaxhp   , :type => Integer
  field :str        , :type => Integer
  field :int        , :type => Integer
  field :dex        , :type => Integer
  field :god        , :type => String  # DONE
  field :duration   , :type => String  # DONE
  field :turn       , :type => Float   # DONE
  field :runes      , :type => Integer
  field :killertype , :type => String
  field :killer     , :type => String
  field :damage     , :type => Integer
  field :piety      , :type => Integer # DONE
  field :end_time   , :type => Time    # Parse from morgue e.g morgue-snwcln-20120516-220145.txt
                                       #                      16th June 2012 at 22:01:45

  belongs_to :player
end
