class Coroner
  def initialize(morgue="")
    # XXX Assume a string for now, should enforce it too perhaps ...
    @morgue = morgue
  end
  
  def parse
    sections = make_sections @morgue

    autopsy = {}
    autopsy[:version] = find_version sections
    autopsy.merge! find_score_char_title_level(sections)
    autopsy.merge! find_race_class_turns_duration(sections)

    return ::Morgue.new(autopsy)
  end

  # TODO - Name split sections to obviate need for repeated scans
  def make_sections(m)
    m.split(/\n{2,}/)
  end
  
  def match_one(sections, re)
    return sections.inject(false) do |result, section|
      match = section.match(re)
      match && !result ? match[1] : result
    end
  end
  
  # XXX Use blocks?
  def match_many(sections, regexps)
    # XXX This is a bit gross, should find the section first then match on that.
    return regexps.keys.inject({}) do |results, to_match|
      m = match_one sections, regexps[to_match]
      m ? results.merge({to_match => m}) : results
    end
  end

  def find_section(sections, re)
    sections.each do |s|
      m = s.match re
      return [s, m] if m
    end
  end
  
  def find_version(sections)
    return match_one sections, / Dungeon Crawl Stone Soup version (\S+)/
  end

  def find_score_char_title_level(sections)
    # 178 Snwcln the Vexing (level 3
    _, match = find_section sections, /\A
       (?<score>\d+)    \s
       (?<character>.*) \s
       the              \s
       (?<title>.*)     \s
       \(level \s (?<level>\d+)
    /x;
    return {} if match.nil?
    return {
      :score     => match[:score].to_i,
      :character => match[:character],
      :title     => match[:title],
      :level     => match[:level].to_i
    }
  end

  def find_race_class_turns_duration(sections)
    # Oh for lazy build attributes ...
    @rbc_re = CrawlCombos.race_background_combo_re unless @rbc_re

    # Snwcln the Vexing (Felid Wanderer)  Turns: 3364, Time: 00:11:02
    # fleugma the Thaumaturge (SEEE)  Turns: 14495, Time: 01:06:50
    _, match = find_section sections, /
       \( #{@rbc_re} \) \s+
       Turns: \s (?<turns>[\d.]+), \s
       Time:  \s (?<duration>[\d:]+)
    /x

    return {:nomatch => 1} if match.nil?

    begin
      # Umm, WTF - http://pastie.org/3886124
      race, background = match[:combo] ? CrawlCombos.abbr2combo(match[:combo]) : [match[:race], match[:background]]
    # Sometimes I see "Can't cast Symbol to Integer" which doesn't make sense if we didn't get match.
    rescue TypeError
      raise Excepion, "match = #{match}"
    end

    return {} unless race && background

    return {
      :race       => race,
      :background => background,
      :turns      => match[:turns].to_f,
      :duration   => match[:duration],
    }
  end

  # Hand scraped from the 0.9.1 char roll screens + new 0.10 bits.
  # This is just some static data with helper static methods.
  module CrawlCombos
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
    };
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
    };
    def CrawlCombos.race_as_re
      Regexp.new('(?:' + RACE.values.join('|') + ')')
    end
    def CrawlCombos.background_as_re
      Regexp.new('(?:' + BACKGROUND.values.join('|') + ')')
    end
    def CrawlCombos.abbr_race_as_re
      Regexp.new('(?:' + RACE.keys.join('|') + ')')      
    end
    def CrawlCombos.abbr_background_as_re
      Regexp.new('(?:' + BACKGROUND.keys.join('|') + ')')
    end
    def CrawlCombos.abbr_combo_re
      Regexp.new( abbr_race_as_re.to_s + abbr_background_as_re.to_s )
    end
    def CrawlCombos.race_background_combo_re
      /# Race Background e.g High Elf Earth Elementalist
       (?: (?<race>#{race_as_re}) [ ] (?<background>#{background_as_re}) )
       # Abbreviated combo e.g HEEE
       | (?<combo>#{abbr_combo_re})
      /x
    end
    def CrawlCombos.abbr2combo(abbr)
      race = RACE[abbr.slice 0,2]
      bkgd = BACKGROUND[abbr.slice 2,4]
      raise Exception, "Unknown combo '#{abbr}'" unless race and bkgd
      return race, bkgd
    end
  end
end

class Morgue < Hash
  def initialize(args)
    # I have been spoilt by Moose, would've used this but instance_variable_set makes inspect empty.
    # via http://stackoverflow.com/questions/2680523/dry-ruby-initialization-with-hash-argument

    # Yes this is lazy.
    self.merge!(args)
  end
end

