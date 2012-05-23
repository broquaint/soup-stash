class Game # Specifically DCSS
  include Mongoid::Document
  
  field :name, :type => String
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
  field :levels_seen , :type => Integer
  field :hp         , :type => Integer
  field :maxhp      , :type => Integer
  field :maxmaxhp   , :type => Integer
  field :str        , :type => Integer
  field :int        , :type => Integer
  field :dex        , :type => Integer
  field :god        , :type => String  # DONE
  field :duration   , :type => Integer # DONE
  field :turn       , :type => Float   # DONE
  field :runes      , :type => Integer
  field :killertype , :type => String
  field :killer     , :type => String
  field :kills      , :type => Integer
  field :damage     , :type => Integer
  field :piety      , :type => Integer # DONE
  field :end_time   , :type => Time    # Parse from morgue e.g morgue-snwcln-20120516-220145.txt
                                       #                      16th June 2012 at 22:01:45

  # key fields
  field :end_time_str, :type => String
  field :combo,        :type => String
  
  belongs_to :player
  key :name, :character, :combo, :end_time_str

  # http://kylebanker.com/blog/2009/12/mongodb-map-reduce-basics/
  def self.popular_combos # TODO Take time/version/etc as options
    map = 'function() { emit(this.race + " " + this.background, { count: 1 }) }'
    red = 'function(k,vals) { var tot = 0; vals.forEach(function(v) { tot += v.count }); return { count: tot }; }'
    combos = Game.collection.map_reduce(map, red, :out => {:inline=>1}, :raw => true)
    combos['results'].collect do |c|
      {
        :race  => c['_id'],
        :count => c['value']['count'].to_i,
      }
    end
  end
 
end
