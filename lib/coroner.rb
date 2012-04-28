class Coroner
  def initialize(morgue="")
    # XXX Assume a string for now
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
    _, match = find_section sections, /\A
       (?<score>\d+)    \s
       (?<character>.*) \s
       the              \s
       (?<title>.*)     \s
       \(level \s (?<level>\d+)
    /x;
    return {} unless match
    return {
      :score     => match[:score].to_i,
      :character => match[:character],
      :title     => match[:title],
      :level     => match[:level].to_i
    }
  end

  def find_race_class_turns_duration(sections)
    @race_re       = CrawlCombos.race_as_re       unless @race_re
    @background_re = CrawlCombos.background_as_re unless @background_re
    _, match = find_section sections, /\A
       (?:.*\sthe\s.*)\s
       \( (?<race>#{@race_re}) \s (?<background>#{@background_re}) \) \s+
       Turns: \s (?<turns>[\d.]+), \s
       Time:  \s (?<duration>[\d:]+)
    /x
    return {} unless match
    return {
      :race       => match[:race],
      :background => match[:background],
      :turns      => match[:turns].to_f,
      :duration   => match[:duration],
    }
  end

  # Hand scraped from the 0.9.1 char roll screens.
  module CrawlCombos
    RACE = [
              "Centaur",
              "Deep Dwarf",
              "Deep Elf",
              "Demigod",
              "Demonspawn",
              "Draconian",
              "Felid",
              "Ghoul",
              "Halfling",
              "High Elf",
              "Hill Orc",
              "Human",
              "Kenku",
              "Kobold",
              "Merfolk",
              "Minotaur",
              "Mountain Dwarf",
              "Mummy",
              "Naga",
              "Ogre",
              "Sludge Elf",
              "Spriggan",
              "Troll",
              "Vampire",
             ];
    BACKGROUND = [
                    "Abyssal Knight",
                    "Air Elementalist",
                    "Artificer",
                    "Assassin",
                    "Berserker",
                    "Chaos Knight",
                    "Conjurer",
                    "Death Knight",
                    "Earth Elementalist",
                    "Enchanter",
                    "Fighter",
                    "Fire Elementalist",
                    "Gladiator",
                    "Healer",
                    "Hunter",
                    "Ice Elementalist",
                    "Monk",
                    "Necromancer",
                    "Priest",
                    "Skald",
                    "Stalker",
                    "Summoner",
                    "Transmuter",
                    "Venom Mage",
                    "Wanderer",
                    "Warper",
                    "Wizard",
                   ];
    def CrawlCombos.race_as_re
      Regexp.new('(?:' + CrawlCombos::RACE.join('|') + ')')
    end
    def CrawlCombos.background_as_re
      Regexp.new('(?:' + CrawlCombos::BACKGROUND.join('|') + ')')
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

