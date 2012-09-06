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
    autopsy.merge! find_resistances_slots(sections, autopsy[:race])
    autopsy.merge! find_killer_ending(sections)
    autopsy.merge! find_kills(sections)
    autopsy.merge! find_visits(sections)
    autopsy.merge! find_stats(sections)
    autopsy.merge! find_state_abilities_runes(sections)

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
    _, match = find_section sections, score_section_re = /\A
      (?<score>\d+)    \s
      (?<character>.*) \s
      the              \s
      (?<title>.*)     \s
      \(level \s (?<level>\d+)
    /x
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
       Time:  \s (?<duration>[\d\s:,]+) $
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
    
    dur_m = duration.match /^(?:(?<days>\d+),\s*)?(?<hours>\d+):(?<minutes>\d\d):(?<seconds>\d\d)\z/

    # XXX Store this somewhere?
    game_in_seconds  = ( dur_m[:hours].to_i * 60 * 60 ) + ( dur_m[:minutes].to_i * 60 ) + dur_m[:seconds].to_i
    game_in_seconds += 3600 * 24 * dur_m[:days].to_i if dur_m[:days].to_i

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

  def find_resistances_slots(sections, race)
    rEquip, _ = find_section sections, /\ARes[.]Fire\s+:/;

    return {} if rEquip.nil?

    resistances = {}
    rTot_re   = %r{(?:[+x.]\s)+}
    rMatch_re = %r{
      ([A-Z][A-Za-z. ]+\S) \s*: \s (#{rTot_re})
    }x

    rEquip.scan(rMatch_re) do |r, t|
      t.gsub! /\s+/, ''
      resistances[r] = if t.length == 1
                         t == '+' ? 'on' : t == '.' ? 'off' : 'disabled'
                       else # Use fractionals?
                         "%d/%d" % [t.count('+'), t.length]
                       end
    end

    equipped_re = %r{([A-Za-z]) - (.*)\z}   # Mmm, fixed width records.
    items       = rEquip.split(/\n/).collect{|line| line[37, line.length-1]}

    slot_list = race != 'Octopode' ? DCSS::EQUIPMENT_SLOTS : DCSS::EQUIPMENT_SLOTS_OP
    equipped  = slot_list.length.times.reduce({}) do |slots, idx|
      has_slot, slot, item = *items[idx].match(equipped_re)
      slots[ DCSS::EQUIPMENT_SLOTS[idx] ] = has_slot ? { :slot => slot, :item => item } : nil
      slots
    end

    return {
      :resistances => resistances,
      :equipped    => equipped
    }
  end

  # TODO Grab "death notice" from score summary section.
  def find_killer_ending(sections)
    notes, _ = find_section sections, /\ANotes$/m
    return {} if notes.nil?

    ret = { :ending => notes.split(/\s*[|]\s*/)[-1].strip } # Last note == ending

    # Only looking for the monster that killed the player, not quits/escapes/etc
    killer = notes.match(/(by|to)\s(\san?)?(?<culprit>\w+[()\w '-]*)( poison)?\s*\z/x)
    return ret if killer.nil?
    return ret.merge({
      :killer => killer[:culprit].sub(/^an? /, ''), # Meh, too lazy to make re above DTRT
    })
  end

  def find_kills(sections)
    # XXX Worth distingusing between own/collateral/other?
    kills = sections.collect{|s| s.match /^(?<v>\d+) creatures vanquished[.]$/m}.reject &:nil?
    return { :kills => kills.reduce(0) {|acc, k| acc + k[:v].to_i } }
  end

  def find_visits(sections)
    # XXX This is a bit fragile.
    return { :levels_seen => match_one(sections, /saw (\d+) of its level/).to_i }
  end

  def find_stats(sections)
    stats, _ = find_section sections, %r{^HP\s+-?\d+/}

    stat_list = %w{HP AC Str MP EV Int Gold SH Dex}
    stat_res  = stat_list.inject({}) do |h, s|
      h.merge({ s => %r{
        #{s} \s+ (?<#{s.downcase}> -?\d+ (?:/\d+)?) # HP -1/12
         (?:\s+\((?<max#{s.downcase}>\d+)\))? \s+   # (13)
      }x })
    end
    numbers = stats.match %r{\A
      #{stat_res.values_at('HP', 'AC', 'Str').join('')}
      XL: \s+  (?<xl>\d+) \s* (?: Next: \s+ (?<next>\d+%) )? \n
      #{stat_res.values_at('MP', 'EV', 'Int').join('')}
      God: \s+ (?: (?<god>\w+[ \w]*) (?:\s \[......\])? \s* )? \n
      #{stat_res.values_at('Gold', 'SH', 'Dex').join('')}
    }x

    return {} if numbers.nil?

    return {
      # TODO Special case hp/maxhp to make the regexps above smaller + simpler
      :hp  => numbers[:hp], # Given "-1/12" should it be the LHS or RHS?
      :maxhp => numbers[:maxhp] && numbers[:maxhp].to_i,
      :ac   => numbers[:ac].to_i,
      :str  => numbers[:str].to_i,
      :xl   => numbers[:xl].to_i,
      :mp   => numbers[:mp], # Given "3/6" should it be the LHS or RHS?
      :ev   => numbers[:ev].to_i,
      :int  => numbers[:int].to_i,
      :gold => numbers[:gold].to_i,
      :sh   => numbers[:sh].to_i,
      :dex  => numbers[:dex].to_i
    }
  end

  def find_state_abilities_runes(sections)
    state_etc, _ = find_section sections, /\A@: /

    state, features, abilities, runes =
      state_etc.gsub(/\n(.[^:])/, ' \1').split(/\n/).collect{|s| s.sub /^.: /m, '' }

    ret = {
      :character_state => state.split(/, /),
      :character_features => features.split(/, /),
      :character_abilities => abilities.split(/, /),
    }

    runes_match = runes && runes.match(%r<(?<found>\d+)/\d+ runes: (?<rune_list>.*)>s)

    ret.merge!({
      :runes     => runes_match[:found].to_i,
      :rune_list => runes_match[:rune_list].scan(/[^,\s]+/m)
    }) if runes_match

    return ret
  end

  # TODO Use Hashie::Mash
  class Morgue < Hash
    def initialize(args)
      # I have been spoilt by Moose, would've used this but instance_variable_set makes inspect empty.
      # via http://stackoverflow.com/questions/2680523/dry-ruby-initialization-with-hash-argument

      # Yes this is lazy.
      self.merge!(args)
    end
  end
end

