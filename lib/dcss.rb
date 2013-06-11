module DCSS
  # TODO - Move all this out of code and into some kind of data.

  RACE = {
    'Centaur'        => 'Ce',
    'Deep Dwarf'     => 'DD',
    'Deep Elf'       => 'DE',
    'Demigod'        => 'Dg',
    'Demonspawn'     => 'Ds',
    'Djinni'         => 'Dj',
    'Draconian'      => 'Dr',
    'Elf'            => 'El', # Removed in 0.3
    'Felid'          => 'Fe',
    'Gargoyle'       => 'Gr',
    'Ghoul'          => 'Gh',
    'Gnome'          => 'Gn', # Removed in 0.6
    'Grey Elf'       => 'GE', # Removed in 0.5
    'Grotesk'        => 'Gr',
    'Halfling'       => 'Ha',
    'High Elf'       => 'HE',
    'Hill Dwarf'     => 'HD', # Removed in 0.3
    'Hill Orc'       => 'HO',
    'Human'          => 'Hu',
    'Kenku'          => 'Ke', # Renamed to Tengu in 0.10
    'Kobold'         => 'Ko',
    'Lava Orc'       => 'LO',
    'Merfolk'        => 'Mf',
    'Minotaur'       => 'Mi',
    'Mountain Dwarf' => 'MD', # Removed in 0.10
    'Mummy'          => 'Mu',
    'Naga'           => 'Na',
    'Octopode'       => 'Op',
    'Ogre'           => 'Og',
    'Ogre-mage'      => 'OM', # Removed in 0.5
    'Sludge Elf'     => 'SE',
    'Spriggan'       => 'Sp',
    'Tengu'          => 'Te',
    'Troll'          => 'Tr',
    'Vampire'        => 'Vp',    
  }
  BACKGROUND = {
    'Abyssal Knight'     => 'AK',
    'Air Elementalist'   => 'AE',
    'Artificer'          => 'Ar',
    'Assassin'           => 'As',
    'Arcane Marksman'    => 'AM',
    'Berserker'          => 'Be',
    'Chaos Knight'       => 'CK',
    'Conjurer'           => 'Cj',
    'Crusader'           => 'Cr', # Renamed to Skald in 0.9
    'Death Knight'       => 'DK',
    'Earth Elementalist' => 'EE',
    'Enchanter'          => 'En',
    'Fighter'            => 'Fi',
    'Fire Elementalist'  => 'FE',
    'Gladiator'          => 'Gl',
    'Healer'             => 'He',
    'Hunter'             => 'Hu',
    'Ice Elementalist'   => 'IE',
    'Jester'             => 'Jr', # April Fool's background.
    'Monk'               => 'Mo',
    'Necromancer'        => 'Ne',
    'Paladin'            => 'Pa', # Removed in 0.8
    'Priest'             => 'Pr',
    'Reaver'             => 'Re', # Removed in 0.8
    'Skald'              => 'Sk',
    'Stalker'            => 'St', # Removed in 0.12
    'Summoner'           => 'Su',
    'Transmuter'         => 'Tm',
    'Thief'              => 'Th', # Removed in 0.7
    'Venom Mage'         => 'VM',
    'Wanderer'           => 'Wn',
    'Warper'             => 'Wa',
    'Wizard'             => 'Wz',
  }

  RACE_ABBR       = RACE.invert
  BACKGROUND_ABBR = BACKGROUND.invert

  # There's always some unique snowflake of a race isn't there?
  DRAC_COLOURS = %w[Red White Green Yellow Grey Black Purple Mottled Pale]
  DRAC_RE      = /(?:(?:#{DRAC_COLOURS.join('|')})\s)/

  def DCSS.combo2abbr(race, background)
    r = RACE[race.sub /^#{DRAC_RE}/, '']
    b = BACKGROUND[background]
    if r and b
      return r + b
    else
      warn "Unknown combo '#{race} #{background}'"
      r = race[0..1] if r.nil?
      b = background[0..1] if b.nil?
      return r + b
    end
  end
  
  def DCSS.race_as_re
    Regexp.new("#{DRAC_RE}?(?:#{RACE.keys.join('|')})")
  end
  def DCSS.background_as_re
    Regexp.new('(?:' + BACKGROUND.keys.join('|') + ')')
  end
  def DCSS.abbr_race_as_re
    Regexp.new('(?:' + RACE.values.join('|') + ')')      
  end
  def DCSS.abbr_background_as_re
    Regexp.new('(?:' + BACKGROUND.values.join('|') + ')')
  end
  def DCSS.abbr_combo_re
    Regexp.new( abbr_race_as_re.to_s + abbr_background_as_re.to_s )
  end
  def DCSS.race_background_re
    /# Race Background e.g High Elf Earth Elementalist
       (?<race>#{race_as_re}) [ ] (?<background>#{background_as_re})
      /x
  end
  def DCSS.abbr2combo(abbr)
    race = RACE_ABBR[abbr.slice 0,2]
    bkgd = BACKGROUND_ABBR[abbr.slice 2,4]
    raise Exception, "Unknown combo '#{abbr}'" unless race and bkgd
    return race, bkgd
  end

  def DCSS.race_and_background_from(combo)
    m = combo.match(/(#{races.join('|')}) (#{backgrounds.join('|')})/)
    return m ? m[1,2] : ['','']
  end

  def DCSS.races
    RACE.keys
  end
  def DCSS.backgrounds
    BACKGROUND.keys
  end
  def DCSS.gods
    GODS
  end
  def DCSS.drac_colours
    DRAC_COLOURS
  end

  BRANCHES = {
    'Abyss'   => 'Abyss',
    'Bailey'  => 'Bailey',
    'Bzr'     => 'Bazaar',
    'Bazaar'  => 'Bazaar',
    'Blade'   => 'Hall of Blades',
    'Coc'     => 'Cocytus',
    'Crypt'   => 'Crypt',
    'D'       => 'Dungeon',
    'Dis'     => 'Iron City of Dis',
    'Elf'     => 'Elven Halls',
    'Geh'     => 'Gehenna',
    'Forest'  => 'Forest',
    'Hell'    => 'Hell',
    'Hive'    => 'Hive', # Removed in 0.10
    'IceCv'   => 'Ice Cave',
    'Lab'     => 'Labyrinth',
    'Lair'    => 'Lair of Beasts',
    'Minitom' => 'Ossuary',
    'Orc'     => 'Orcish Mines',
    'Ossuary' => 'Ossuary',
    'Pan'     => 'Pandemonium',
    'Sewer'   => 'Sewers',
    'Shoal'   => 'Shoals',
    'Shoals'  => 'Shoals',
    'Slime'   => 'Slime Pits',
    'Snake'   => 'Snake Pit',
    'Spider'  => "Spider's Nest",
    'Swamp'   => 'Swamp',
    'Tar'     => 'Tartarus',
    'Temple'  => 'Templte',
    'Tomb'    => 'Tomb',
    'Trove'   => 'Trove',
    'Vaults'  => 'Vaults',
    'Volcano' => 'Volcano',
    'Wizlab'  => 'WizLab',
    'Zig'     => 'Ziggurat',
    'Zot'     => 'Realm of Zot',
  };

  def DCSS.branches
    BRANCHES.values
  end
  def DCSS.branch_for_abbr(abbr)
    BRANCHES[abbr]
  end
  def DCSS.branch_re
    Regexp.new('(?:' + branches.join('|') + ')')
  end

  RESISTANCES_ORDER = [
                       'Resist Fire',
                       'Resist Cold',
                       'Life Protection',
                       'Resist Acid',
                       'Resist Poison',
                       'Resist Electric',
                       'Sustain Abilities',
                       'Resist Mutation',
                       'Resist Rotting',
                       'Sappovore',

                       'See Invisible',
                       'Warding',
                       'Conservation',
                       'Resist Corrosion',
                       'Clarity',
                       'Spirit Shield',
                       'Stasis',
                       'Control Telport',
                       'Levitation',
                       'Control Flight',
                      ]

  RESISTANCES_MAP = {
    "Res.Fire"    => 'Resist Fire',
    "See Invis."  => 'See Invisible',
    "Res.Cold"    => 'Resist Cold',
    "Warding"     => 'Warding',
    "Life Prot."  => 'Life Protection',
    "Conserve"    => 'Conservation',
    "Res.Poison"  => 'Resist Poison',
    "Res.Corr."   => 'Resist Corrosion',
    "Res.Acid."   => 'Resist Acid',
    "Res.Elec."   => 'Resist Electric',
    "Clarity"     => 'Clarity',
    "Sust.Abil."  => 'Sustain Abilities',
    "Spirit.Shd"  => 'Spirit Shield',
    "Res.Mut."    => 'Resist Mutation',
    "Stasis"      => 'Stasis',
    "Res.Rott."   => 'Resist Rotting',
    "Ctrl.Telep." => 'Control Telport',
    "Saprovore"   => 'Sappovore',
    "Levitation"  => 'Levitation',
    "Ctrl.Flight" => 'Control Flight',
  }  

  EQUIPMENT_SLOTS = [
                     'weapon',
                     'armour',
                     'shield',
                     'helmet',
                     'cloak',
                     'gloves',
                     'boots',
                     'amulet',
                     'right ring',
                     'left ring',
                    ]
  EQUIPMENT_SLOTS_OP = [
                     'weapon',
                     'armour',
                     'helmet',
                     'amulet',
                     'ring',
                     'ring',
                     'ring',
                     'ring',
                     'ring',
                     'ring',
                     'ring',
                     'ring',
                    ]

  INVENTORY_TYPES = [
                     'Hand weapons',
                     'Missiles',
                     'Armour',
                     'Magical devices',
                     'Comestibles',
                     'Scrolls',
                     'Jewellery',
                     'Potions',
                     'Books',
                     'Magical staves',
                     'Rods',
                     'Orbs of Power',
                     'Miscellaneous',
                     'Carrion',
                    ]

  SKILL_STATE = {
    '+' => 'selected',
    '-' => 'deselected',
    '*' => 'focused',
    'O' => 'max',
    ' ' => 'untrainable',
  }

  SPELL_TYPES = {
    'Air'  => 'Air',
    'Chrm' => 'Charms',
    'Conj' => 'Conjurations',
    'Erth' => 'Earth',
    'Fire' => 'Fire',
    'Hex'  => 'Hexes',
    'Ice'  => 'Ice',
    'Necr' => 'Necromancy',
    'Pois' => 'Poison',
    'Summ' => 'Summoning',
    'Tloc' => 'Translocation',
    'Trmt' => 'Transmutation',
  }

  def DCSS.spell_type_re
    spells = SPELL_TYPES.keys.join('|')
    Regexp.new("(?:(?:#{spells})(?:/(?:#{spells}))?)")
  end

  def DCSS.inventory_types
    INVENTORY_TYPES
  end
  def DCSS.spell_types
    SPELL_TYPES
  end
  def DCSS.order_of_resistances
    RESISTANCES_ORDER
  end

  GODS = [
    'Ashenzari',
    'Beogh',
    'Cheibriados',
    'Elyvilon',
    'Fedhas', # TODO normalize
    'Feawn', # aka Fedhas
    'Jiyva',
    'Kikubaaqudgha',
    'Lugonu',
    'Makhleb',
    'Nemelex Xobeh',
    'Okawaru',
    'Sif Muna',
    'the Shining One', # TODO normalize
    'Trog',
    'Vehumet',
    'Xom',
    'Yredelemnul',
    'Zin',
  ]

  # 19:28 < Henzell> rcfile[1/5]: Accessible via www: CAO: http://crawl.akrasiac.org/rcfiles/crawl-{0.7|0.8|0.9|0.10|git|lorcs}/$name.rc CDO:
  # http://crawl.develz.org/configs/{ancient|0.6|0.7|0.8|0.9|0.10|trunk}/$name.rc CSZO: http://dobrazupa.org/rcfiles/crawl-{0.10|0.11|git}/$name.rc

  # XXX Requires manual updates!
  TRUNK_VERSION = '0.13';
  # Based on servers.yml from dcss_henzell
  MORGUE_PATHS = {
    'crawl.develz.org'     => lambda {|g|
      is_trunk = g.full_version =~ /^0[.]\d+(?:[.]\d+)?-[a-z]+\d+/
      path     = g.version == TRUNK_VERSION || is_trunk ? 'trunk' : g.version
      "http://crawl.develz.org/morgues/#{path}/"
    },
    'crawl.akrasiac.org'   => lambda {|g| 'http://crawl.akrasiac.org/rawdata/' },
    'dobrazupa.org'        => lambda {|g| 'http://dobrazupa.org/morgue/' },
    'crawlus.somatika.net' => lambda {|g| 'http://crawlus.somatika.net/dumps/' },
    'rl.heh.fi'            => lambda {|g| 'http://rl.heh.fi/trunk/stuff/' }
  }

  def DCSS.morgue_uri_for(host, game, filename)
    URI.parse( MORGUE_PATHS[host].call(game) + filename )
  end

  def DCSS.full_version_to_major_version(v)
    # e.g "0.12.1-43-gbc5e171" => "0.12"
    v.sub /^(\d+[.]\d+).*/, '\1'
  end

  HOST_TO_ABBR = {
    'dobrazupa.org'      => 'CSZO',
    'crawl.develz.org'   => 'CDO',
    'crawl.akrasiac.org' => 'CAO',
  }
  def DCSS.abbr_for_host(uri)
    uri = URI.parse(uri) if uri.is_a? String
    HOST_TO_ABBR[uri.host]
  end

  # Pilfered from dcss_henzell/crawl-data.yml, would be good to pull in dynamically.
  UNIQUES = [
             "Ijyb",
             "Blork the orc",
             "Blork",
             "Urug",
             "Erolcha",
             "Snorg",
             "Polyphemus",
             "Adolf",
             "Antaeus",
             "Xtahua",
             "Tiamat",
             "Boris",
             "Murray",
             "Terence",
             "Jessica",
             "Sigmund",
             "Edmund",
             "Psyche",
             "Donald",
             "Michael",
             "Joseph",
             "Erica",
             "Josephine",
             "Harold",
             "Norbert",
             "Jozef",
             "Agnes",
             "Maud",
             "Louise",
             "Francis",
             "Frances",
             "Rupert",
             "Wayne",
             "Duane",
             "Norris",
             "Frederick",
             "Margery",
             "Mnoleg",
             "Lom Lobon",
             "Cerebov",
             "Gloorx Vloq",
             "Geryon",
             "Dispater",
             "Asmodeus",
             "Ereshkigal",
             "the royal jelly",
             "the Lernaean hydra",
             "Dissolution",
             "Azrael",
             "Prince Ribbit",
             "Sonja",
             "Ilsuiw",
             "Nergalle",
             "Saint Roka",
             "Roxanne",
             "Eustachio",
             "Nessos",
             "Dowan",
             "Duvessa",
             "Grum",
             "Crazy Yiuf",
             "Gastronok",
             "Pikel",
             "Menkaure",
             "Khufu",
             "Aizul",
             "Purgy",
             "Kirke",
             "Maurice",
             "Nikola",
             "Mara",
             "Grinder",
             "Mennas",
             "Chuck",
             "the iron giant",
             "Nellie",
             "Wiglaf",
             "Jory",
             "Terpsichore",
             "Ignacio",
             "Fannar",
             "Arachne",
             "Cigotuvi's Monster"
            ]

  # As mapped in IngestLogfile::Transformer
  LOGFILE_FIELDS = [
    "background",
    "branch",
    "character",
    "combo",
    "damage",
    "deepest_level",
    "dex",
    "duration",
    "end_time",
    "ending",
    "game_type",
    "god",
    "gold",
    "gold_found",
    "gold_spent",
    "hp",
    "int",
    "invocant_killer",
    "kill_total",
    "killer",
    "killer_type",
    "killer_weapon",
    "killer_weapon_desc",
    "level",
    "map_name",
    "maxhp",
    "maxmaxhp",
    "name",
    "place_abbr",
    "race",
    "score",
    "server",
    "skill",
    "skill_level",
    "source_damage",
    "start_time",
    "str",
    "terse_ending",
    "title",
    "turn_damage",
    "turns",
    "version",
    "xl",
  ]

  def DCSS.is_logfile_field(f)
    LOGFILE_FIELDS.include?(f.to_s)
  end
end
