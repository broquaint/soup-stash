require 'soupstash/model'

require 'reindeer'

class SoupStash::Model::Game < Reindeer
  has :name, is_a: String
  # XXX All of it?
  has :morgue, is_a: String

  has :was_local, is_a: Boolean # Perhaps should be an enum?
  
  # via https://github.com/greensnark/dcss_scoring/blob/master/databasedesign.txt
  has :start_time , is_a: Time    # endtime - duration
  has :score      , is_a: Integer # DONE
  has :race       , is_a: String  # DONE
  has :background , is_a: String  # DONE
  has :version    , is_a: String  # DONE
  has :character  , is_a: String  # DONE
  has :xl         , is_a: Integer # DONE == experience level
  has :title      , is_a: String  # DONE
  has :place      , is_a: String  # DONE level 7 of the dungeon
  has :level      , is_a: Integer # DONE       7
  has :branch     , is_a: String  # DONE                dungeon
  has :levels_seen , is_a: Integer # DONE
  has :hp         , is_a: String  # DONE
  has :maxhp      , is_a: Integer # DONE
  has :maxmaxhp   , is_a: Integer # DONE
  has :mp         , is_a: String  # DONE
  has :ev         , is_a: Integer # DONE
  has :ac         , is_a: Integer # DONE
  has :str        , is_a: Integer # DONE
  has :int        , is_a: Integer # DONE
  has :dex        , is_a: Integer # DONE
  has :sh         , is_a: Integer # DONE
  has :duration         , is_a: String  # DONE
  has :duration_seconds , is_a: Integer # DONE
  has :turns      , is_a: Float   # DONE
  has :runes      , is_a: Integer # DONE
  has :rune_list  , is_a: Array   # DONE
  has :killer     , is_a: String  # DONE
  has :end_time   , is_a: Time    # Parse from morgue e.g morgue-snwcln-20120516-220145.txt
                                       #                      16th June 2012 at 22:01:45

  has :ending, is_a: String

  has :piety,    is_a: String
  has :god,      is_a: String
  has :standing, is_a: String

  has :character_state,     is_a: Array # @: stealthy, fast, etc
  has :character_features,  is_a: Array # A: horns, claws, teleportitis, etc
  has :character_abilities, is_a: Array # a: Bend Time, Evoke Blink, etc

  has :resistances, is_a: Object # Res.Fire  : + . .
  has :equipped,    is_a: Object # p - +2 leather armour

  has :inventory, is_a: Object # { slot: { item: String, desc: String, type: String } }

  has :skills, is_a: Object # { skill: { state: String, level: Float } }

  has :spells_left,  is_a: Integer
  has :spells_known, is_a: Array # [ { slot, spell, type, power, fail_rate, level, hunger } ]

  has :map, is_a: String

  has :kills,       is_a: Object # { vanquisher: [{ amount: Int, creature: String, location: String }] }
  has :kill_total,  is_a: Integer
  has :ghost_kills, is_a: Array # [{:kills[v][idx] + type: String}]

  has :notes, is_a: Array # [{ turn: Int, place: String, note: String }]

  ## Hass from logfile
  # New hass with exact logfile mappings
  has :game_type , is_a: String
  has :gold      , is_a: Integer
  has :splat     , is_a: Boolean
  has :tiles     , is_a: Boolean
  has :place_abbr, is_a: String
  has :map_name  , is_a: String

  # New hass needing mapping
  has :deepest_level      , is_a: Integer # was absdepth
  has :killer_weapon      , is_a: String  # was ckaux
  has :damage             , is_a: Integer # was dam
  has :gold_found         , is_a: Integer # was goldfound
  has :gold_spent         , is_a: Integer # was goldspent
  has :invocant_killer    , is_a: String  # was ikiller
  has :killer_weapon_desc , is_a: String  # was kaux
  has :killer_type        , is_a: String  # was ktyp
  has :source_damage      , is_a: Integer # was sdam
  has :skill              , is_a: String  # was sk
  has :skill_level        , is_a: Integer # was sklev
  has :server             , is_a: String  # was src
  has :turn_damage        , is_a: Integer # was tdam
  has :terse_ending       , is_a: String

  # Should be useful when local games are uploadable.
  has :from_log_file,   is_a: Boolean
  # Makes display simpler.
  has :has_morgue_file, is_a: Boolean

  # key hass
  has :end_time_str, is_a: String
  has :combo,        is_a: String
end
