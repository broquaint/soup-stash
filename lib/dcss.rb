module DCSS
  # TODO - Move all this out of code and into some kind of data.

  RACE = {
    'Ce' => 'Centaur',
    'DD' => 'Deep Dwarf',
    'DE' => 'Deep Elf',
    'Dg' => 'Demigod',
    'Ds' => 'Demonspawn',
    'Dj' => 'Djinni',
    'Dr' => 'Draconian',
    'Fe' => 'Felid',
    'Gh' => 'Ghoul',
    'Gr' => 'Gargoyle',
    'Ha' => 'Halfling',
    'HE' => 'High Elf',
    'HO' => 'Hill Orc',
    'Hu' => 'Human',
    'Ke' => 'Kenku',
    'Ko' => 'Kobold',
    'LO' => 'Lava Orc',
    'Mf' => 'Merfolk',
    'Mi' => 'Minotaur',
    'MD' => 'Mountain Dwarf',
    'Mu' => 'Mummy',
    'Na' => 'Naga',
    'Op' => 'Octopode',
    'Og' => 'Ogre',
    'SE' => 'Sludge Elf',
    'Sp' => 'Spriggan',
    'Te' => 'Tengu',
    'Tr' => 'Troll',
    'Vp' => 'Vampire',
  }
  BACKGROUND = {
    'AK' => 'Abyssal Knight',
    'AE' => 'Air Elementalist',
    'Ar' => 'Artificer',
    'As' => 'Assassin',
    'AM' => 'Arcane Marksman',
    'Be' => 'Berserker',
    'CK' => 'Chaos Knight',
    'Cj' => 'Conjurer',
    'DK' => 'Death Knight',
    'EE' => 'Earth Elementalist',
    'En' => 'Enchanter',
    'Fi' => 'Fighter',
    'FE' => 'Fire Elementalist',
    'Gl' => 'Gladiator',
    'He' => 'Healer',
    'Hu' => 'Hunter',
    'IE' => 'Ice Elementalist',
    'Jr' => 'Jester',
    'Mo' => 'Monk',
    'Ne' => 'Necromancer',
    'Pr' => 'Priest',
    'Sk' => 'Skald',
    'St' => 'Stalker',
    'Su' => 'Summoner',
    'Tm' => 'Transmuter',
    'VM' => 'Venom Mage',
    'Wn' => 'Wanderer',
    'Wa' => 'Warper',
    'Wz' => 'Wizard',
  }

  RACE_ABBR       = RACE.invert
  BACKGROUND_ABBR = BACKGROUND.invert

  # There's always some unique snowflake of a race isn't there?
  DRAC_COLOURS = %w[Red White Green Yellow Grey Black Purple Mottled Pale]
  DRAC_RE      = /(?:(?:#{DRAC_COLOURS.join('|')})\s)/

  def DCSS.combo2abbr(race, background)
    r = RACE_ABBR[race.sub /^#{DRAC_RE}/, '']
    b = BACKGROUND_ABBR[background]
    raise Exception, "Unknown combo '#{race} #{background}'" unless r and b
    return r + b
  end
  
  def DCSS.race_as_re
    Regexp.new("#{DRAC_RE}?(?:#{RACE.values.join('|')})")
  end
  def DCSS.background_as_re
    Regexp.new('(?:' + BACKGROUND.values.join('|') + ')')
  end
  def DCSS.abbr_race_as_re
    Regexp.new('(?:' + RACE.keys.join('|') + ')')      
  end
  def DCSS.abbr_background_as_re
    Regexp.new('(?:' + BACKGROUND.keys.join('|') + ')')
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
    race = RACE[abbr.slice 0,2]
    bkgd = BACKGROUND[abbr.slice 2,4]
    raise Exception, "Unknown combo '#{abbr}'" unless race and bkgd
    return race, bkgd
  end

  BRANCHES = {
    'Abyss'   => 'Abyss',
    'Bailey'  => 'Bailey',
    'Bazaar'  => 'Bazaar',
    'Blade'   => 'Hall of Blades',
    'Coc'     => 'Cocytus',
    'Crypt'   => 'Crypt',
    'D'       => 'Dungeon',
    'Dis'     => 'Iron City of Dis',
    'Elf'     => 'Elven Halls',
    'Geh'     => 'Gehenna',
    'Hell'    => 'Hell',
    'IceCv'   => 'Ice Cave',
    'Lab'     => 'Labyrinth',
    'Lair'    => 'Lair of Beasts',
    'Orc'     => 'Orcish Mines',
    'Ossuary' => 'Ossuary',
    'Pan'     => 'Pandemonium',
    'Sewer'   => 'Sewers',
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

  def DCSS.branch_re
    Regexp.new('(?:' + BRANCHES.values.join('|') + ')')
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

  GODS = [
          'Ashenzari',
          'Beogh',
          'Cheibriados',
          'Elyvilon',
          'Fedhas', # TODO normalize
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

  TRUNK_VERSION = '0.13';
  # Based on servers.yml from dcss_henzell
  MORGUE_PATHS = {
    'crawl.develz.org'     => lambda {|g|
      number   = g.version[/^\d.\d\d?/]
      is_trunk = g.version =~ /^0[.]\d+(?:[.]\d+)?-[a-z]+\d+/
      path     = number == TRUNK_VERSION || is_trunk ? 'trunk' : number
      "http://crawl.develz.org/morgues/#{path}/"
    },
    'crawl.akrasiac.org'   => lambda {|g| 'http://crawl.akrasiac.org/rawdata/' },
    'dobrazupa.org'        => lambda {|g| 'http://dobrazupa.org/morgue/' },
    'crawlus.somatika.net' => lambda {|g| 'http://crawlus.somatika.net/dumps/' },
    'rl.heh.fi'            => lambda {|g| 'http://rl.heh.fi/trunk/stuff/' }
  }

  HOST_TO_ABBR = {
    'dobrazupa.org'      => 'CSZO',
    'crawl.develz.org'   => 'CDO',
    'crawl.akrasiac.org' => 'CAO',
  }

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
    'background',
    'branch',
    'character',
    'combo',
    'deepest_level',
    'dex',
    'game_type',
    'god',
    'gold',
    'hp',
    'int',
    'killer',
    'level',
    'maxhp',
    'maxmaxhp',
    'place_abbr',
    'race',
    'skill',
    'skill_level',
    'start_time',
    'str',
    'title',
    'version',
    'xl',
  ]
end
