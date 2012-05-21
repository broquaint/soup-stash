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

  BRANCHES = [
              'Dungeon',
              'Ecumenical Temple',
              'Orcish Mines',
              'Elven Halls',
              'Lair of Beasts',
              'Swamp',
              'Snake Pit',
              'Slime Pits',
              'Shoals',
              'Vaults',
              'Crypt',
              'Tomb',
              'Hall of Blades',
              'Hell',
              'Vestibule of Hell',
              'Cocytus',
              'Gehenna',
              'Tartarus',
              'Iron City of Dis',
              'Realm of Zot',
              'Pandemonium',
              'Abyss',
              'Bailey',
              'Bazaar',
              'Ice Cave',
              'Labyrinth',
              'Ossuary',
              'Sewers',
              "Spider's Nest",
              'Treasure trove',
              'Volcano',
              'Wizard Laboratory',
              'Ziggurat',
             ];

  def DCSS.branch_re
    Regexp.new('(?:' + BRANCHES.join('|') + ')')
  end
end

