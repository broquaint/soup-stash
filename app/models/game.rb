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
  field :levels_seen , :type => Integer # DONE
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
  field :killer     , :type => String  # DONE
  field :kills      , :type => Integer # DONE
  field :damage     , :type => Integer
  field :piety      , :type => Integer # DONE
  field :end_time   , :type => Time    # Parse from morgue e.g morgue-snwcln-20120516-220145.txt
                                       #                      16th June 2012 at 22:01:45

  # key fields
  field :end_time_str, :type => String
  field :combo,        :type => String
  
  belongs_to :player
  field :_id, :type => String, :default => ->{
    "%s-%s-%s-%s" % [name, character, combo, end_time_str]
  }

  # http://kylebanker.com/blog/2009/12/mongodb-map-reduce-basics/
  def self.popular_combos # TODO Take time/version/etc as options
    map = 'function() { emit(this.race + " " + this.background, { count: 1 }) }'
    red = 'function(k,vals) { var tot = 0; vals.forEach(function(v) { tot += v.count }); return { count: tot }; }'
    Game.map_reduce(map, red).out(:inline=>1).collect do |c|
      {
        :race  => c['_id'],
        :count => c['value']['count'].to_i,
      }
    end
  end

  
  def self.character_favourites(character) # TODO Take time/version/etc as options
    # XXX db.eval(File.read('underscore.js'))
    map = %Q{
      function() {
        var e = { race: {}, background: {}, god: {} },
           me = this;
        // { race: { val: 'High Elf', count: 1 } }
        ['race','background','god'].forEach(function(i) { e[i][me[i] || 'none'] = 1; });
        emit(this.character, e);
      }
    }

    red = %Q{
      function(k, vals) {
        var t = { race: {}, background: {}, god: {} };
        // Oh for CoffeeScript!
        vals.forEach(function(v) {
          ['race','background','god'].forEach(function(i) {
            for(var p in v[i])
              t[i][p] = 1 + (p in t[i] ? t[i][p] : 0);
          });
        });
        return t;
      }
    }

    faves = Game.where(:character => character).map_reduce(map, red).out(:inline=>1)
    return {} if faves.empty?
    return {
      :race       => faves.first['value']['race'],
      :background => faves.first['value']['background'],
      :god        => faves.first['value']['god'],
    }
  end
 
end
