require 'dcss'
require 'date'

class DCSS::Coroner
  def initialize(morgue="", filename=nil)
    # XXX Assume a string for now, should enforce it too perhaps ...
    @morgue   = morgue
    @filename = filename # This interface is getting real ugly :S
  end
  
  def parse
    sections = make_sections @morgue

    autopsy = { :name => 'dcss' }
    autopsy[:version] = find_version sections
    autopsy.merge! find_score_char_title_level(sections)
    autopsy.merge! find_place_god_piety_hunger(sections)
    autopsy.merge! find_race_class_turns_duration(sections)
    autopsy.merge! discern_times(autopsy[:duration], @filename)

    return Morgue.new(autopsy)
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

  # TODO Fails on Zot Defense + Sprint
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
    @rbc_re = DCSS.race_background_combo_re unless @rbc_re

    # Snwcln the Vexing (Felid Wanderer)  Turns: 3364, Time: 00:11:02
    # fleugma the Thaumaturge (SEEE)  Turns: 14495, Time: 01:06:50
    _, match = find_section sections, /
       \( #{@rbc_re} \) \s+
       Turns: \s (?<turns>[\d.]+), \s
       Time:  \s (?<duration>[\d:]+)
    /x

    return {} if match.nil?

    race, background = match[:combo] ? DCSS.abbr2combo(match[:combo]) : [match[:race], match[:background]]
    
    return {} unless race && background

    return {
      :race       => race,
      :background => background,
      :turns      => match[:turns].to_f,
      :duration   => match[:duration],
    }
  end

  
  def discern_times(duration, morgue_name)
    return {} if duration.nil? or morgue_name.nil?
    # morgue-snwcln-20120516-220145.txt
    dt_m = @filename.match /\bmorgue-[^-]+-(?<year>\d{4})(?<month>\d\d)(?<day>\d\d)-(?<hour>\d\d)(?<minute>\d\d)(?<second>\d\d)[.]/
    return {} unless dt_m

    end_dt = DateTime.new *%w{year month day hour minute second}.collect{|p| dt_m[p].to_i}
    
    dur_m = duration.match /^(?<hours>\d+):(?<minutes>\d\d):(?<seconds>\d\d)\z/

    # XXX Store this somewhere?
    game_in_seconds = ( dur_m[:hours].to_i * 60 * 60 ) + ( dur_m[:minutes].to_i * 60 ) + dur_m[:seconds].to_i

    # Casting to Time here results in the desired time but then we need to
    # cast end_dt as well in the resultant hash. Also don't want to care about
    # timezone either. Could just stringify perhaps ...
    start_dt = end_dt.to_time - game_in_seconds

    return {
      :start_time => start_dt,
      :end_time   => end_dt.to_time,
      :duration   => game_in_seconds,
    }
  end
  
  def find_place_god_piety_hunger(sections)
    # XXX Won't match everything yet e.g You were a toy of Xom
    place_religion = match_many sections, {
      :place  => /You (?:were [oi]n )?([\w\s]+)[.]$/,
      :god    => /You worshipped ([\s\w]+)[.]/,
      :piety  => /^[\w\s]+ was ([\w\s]+) (?:by your worship|with you)?[.]$/,
#      :hunger => /^You were ((?:not )?hungry|full)/, XXX Worth including?
    }
    
    lvl    = place_religion[:place].match /(\d+)/
    branch = place_religion[:place].match /(#{DCSS.branch_re})/i

    place_religion[:lvl]    = lvl[0].to_i if lvl
    place_religion[:branch] = branch[0]   if branch
    
    return place_religion
  end

  class Morgue < Hash
    def initialize(args)
      # I have been spoilt by Moose, would've used this but instance_variable_set makes inspect empty.
      # via http://stackoverflow.com/questions/2680523/dry-ruby-initialization-with-hash-argument

      # Yes this is lazy.
      self.merge!(args)
    end
  end
end
