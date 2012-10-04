require 'soupstash/model'

class SoupStash::Model::Game
  include Mongoid::Document

  # TODO Use crawl/morgue/whatever instead of "game"
  store_in collection: 'games'
  
  field :name, :type => String
  # XXX All of it?
  field :morgue, :type => String

  field :was_local, :type => Boolean # Perhaps should be an enum?
  
  # via https://github.com/greensnark/dcss_scoring/blob/master/databasedesign.txt
  field :start_time , :type => Time    # endtime - duration
  field :character  , :type => String
  field :score      , :type => Integer # DONE
  field :race       , :type => String  # DONE
  field :background , :type => String  # DONE
  field :version    , :type => String  # DONE
  field :character  , :type => String  # DONE
  field :xl         , :type => Integer # DONE == experience level
  field :title      , :type => String  # DONE
  field :place      , :type => String  # DONE level 7 of the dungeon
  field :level      , :type => Integer # DONE       7
  field :branch     , :type => String  # DONE                dungeon
  field :levels_seen , :type => Integer # DONE
  field :hp         , :type => String  # DONE
  field :maxhp      , :type => Integer # DONE
  field :maxmaxhp   , :type => Integer # DONE
  field :mp         , :type => String  # DONE
  field :ev         , :type => Integer # DONE
  field :ac         , :type => Integer # DONE
  field :str        , :type => Integer # DONE
  field :int        , :type => Integer # DONE
  field :dex        , :type => Integer # DONE
  field :sh         , :type => Integer # DONE
  field :duration         , :type => String  # DONE
  field :duration_seconds , :type => Integer # DONE
  field :turns      , :type => Float   # DONE
  field :runes      , :type => Integer # DONE
  field :rune_list  , :type => Array   # DONE
  field :killer     , :type => String  # DONE
  field :end_time   , :type => Time    # Parse from morgue e.g morgue-snwcln-20120516-220145.txt
  #                      16th June 2012 at 22:01:45

  field :ending, :type => String

  field :piety,    :type => String
  field :god,      :type => String
  field :standing, :type => String

  field :character_state,     :type => Array # @: stealthy, fast, etc
  field :character_features,  :type => Array # A: horns, claws, teleportitis, etc
  field :character_abilities, :type => Array # a: Bend Time, Evoke Blink, etc

  field :resistances, :type => Object # Res.Fire  : + . .
  field :equipped,    :type => Object # p - +2 leather armour

  field :inventory, :type => Object # { slot: { item: String, desc: String, type: String } }

  field :skills, :type => Object # { skill: { state: String, level: Float } }

  field :spells_left,  :type => Integer
  field :spells_known, :type => Array # [ { slot, spell, type, power, fail_rate, level, hunger } ]

  field :map, :type => String

  field :kills,       :type => Object # { vanquisher: [{ amount: Int, creature: String, location: String }] }
  field :kill_total,  :type => Integer
  field :ghost_kills, :type => Array # [{:kills[v][idx] + type: String}]

  field :notes, :type => Array # [{ turn: Int, place: String, note: String }]

  ## Fields from logfile
  # New fields with exact logfile mappings
  field :game_type , :type => String
  field :gold      , :type => Integer
  field :splat     , :type => Boolean
  field :tiles     , :type => Boolean
  field :place_abbr, :type => String
  field :map_name  , :type => String

  # New fields needing mapping
  field :deepest_level      , :type => Integer # was absdepth
  field :killer_weapon      , :type => String  # was ckaux
  field :damage             , :type => Integer # was dam
  field :gold_found         , :type => Integer # was goldfound
  field :gold_spent         , :type => Integer # was goldspent
  field :invocant_killer    , :type => String  # was ikiller
  field :killer_weapon_desc , :type => String  # was kaux
  field :killer_type        , :type => String  # was ktyp
  field :source_damage      , :type => Integer # was sdam
  field :skill              , :type => String  # was sk
  field :skill_level        , :type => Integer # was sklev
  field :server             , :type => String  # was src
  field :turn_damage        , :type => Integer # was tdam
  field :terse_ending       , :type => String

  # A bit gross but simplifies things elsewhere e.g in display.
  field :from_log_file, :type => Boolean

  # key fields
  field :end_time_str, :type => String
  field :combo,        :type => String

  belongs_to :player
  field :_id, :type => String, :default => ->{
    "%s-%s-%s-%s" % [name, character, combo, end_time_str]
  }

  def won
    ending == 'Escaped with the Orb!' # A bit fragile but it'll do.
  end

  # http://kylebanker.com/blog/2009/12/mongodb-map-reduce-basics/
  def self.popular_combos # TODO Take time/version/etc as options
    return [] if Game.count == 0

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
    return {} if Game.count == 0

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
