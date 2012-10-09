module DCSS
  RACE = {
    'Ce' => 'Centaur',
    'DE' => 'Deep Dwarf',
    'DD' => 'Deep Elf',
    'Dg' => 'Demigod',
    'Ds' => 'Demonspawn',
    'Dr' => 'Draconian',
    'Fe' => 'Felid',
    'Gh' => 'Ghoul',
    'Ha' => 'Halfling',
    'HE' => 'High Elf',
    'HO' => 'Hill Orc',
    'Hu' => 'Human',
    'Ke' => 'Kenku',
    'Ko' => 'Kobold',
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

  RACE_ABBR       = Hash[ *RACE.flatten.reverse ]
  BACKGROUND_ABBR = Hash[ *BACKGROUND.flatten.reverse ]

  # There's always some unique snowflake of a race isn't there?
  DRAC_RE = /(?:(?:Red|White|Green|Yellow|Grey|Black|Purple|Mottled|Pale)\s)/

  def DCSS.combo2abbr(race, background)
    r = RACE_ABBR[race.sub /^#{DRAC_RE}/, '']
    b = BACKGROUND_ABBR[background]
    raise Exception, "Unknown combo '#{race} #{background}'" unless r and b
    return r + b
  end
  
  def DCSS.race_as_re
    Regexp.new("#{DRAC_RE}?(?:" + RACE.values.join('|') + ')')
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
  def DCSS.race_background_combo_re
    /# Race Background e.g High Elf Earth Elementalist
       (?: (?<race>#{race_as_re}) [ ] (?<background>#{background_as_re}) )
       # Abbreviated combo e.g HEEE
       | (?<combo>#{abbr_combo_re})
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
                     'Missiles',
                     'Armour',
                     'Magical devices',
                     'Comestibles',
                     'Scrolls',
                     'Jewellery',
                     'Potions',
                     'Books',
                     'Magical staves',
                     'Orbs of Power',
                     'Miscellaneous',
                    ]

  SKILL_STATE = {
    '+' => 'selected',
    '-' => 'deselected',
    '*' => 'focused',
    'O' => 'max',
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
    Regexp.new('(?:(?:' + SPELL_TYPES.keys.join('|') + ')/?)+')
  end
end
