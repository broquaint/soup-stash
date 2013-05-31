require 'dcss'
require 'date'

class DCSS::Coroner
  def initialize(morgue="", filename=nil)
    # XXX Assume a string for now, should enforce it too perhaps ...
    @morgue   = morgue
    @filename = filename # This interface is getting real ugly :S
  end
  
  def parse
    # XXX Might be simpler just to use blocks given how custom morgues can be.
    blocks   = make_blocks @morgue
    sections = make_sections @morgue

    autopsy = { :name => 'crawl', :morgue => '' } # XXX Too noisy for now - @morgue }
    autopsy[:version] = find_version blocks
    autopsy[:tiles]   = check_if_tiles blocks
    # TODO order by default appearance in moregues
    autopsy.merge! find_score_char_title(blocks)
    autopsy.merge! find_place_god_piety_hunger(sections)
    autopsy.merge! find_race_background(blocks)
    autopsy.merge! find_turns_duration(blocks)
    autopsy.merge! discern_times(autopsy[:duration], @filename)
    autopsy.merge! find_resistances_slots(blocks, autopsy[:race])
    autopsy.merge! find_killer_ending(blocks)
    autopsy.merge! find_kills(sections)
    autopsy.merge! find_visits(blocks)
    autopsy.merge! find_stats(blocks)
    autopsy.merge! find_state_abilities_runes(blocks)
    autopsy.merge! find_map(sections)
    autopsy.merge! understand_inventory(sections)
    autopsy.merge! find_skills(blocks)
    autopsy.merge! find_spells(sections)
    autopsy.merge! find_notes(blocks)

    return Morgue.new(autopsy)
  end
  
  # TODO - Name split blocks to obviate need for repeated scans
  def make_blocks(m)
    m.split(/\n{2,}/)
  end
  # TODO - Name sections to obviate need for repeated scans
  def make_sections(m)
    m.split(/\n{3,}/)
  end
  
  def match_one(blocks, re)
    return blocks.inject(false) do |result, block|
      match = block.match(re)
      match && !result ? match[1] : result
    end
  end
  
  def find_in(blocks, re)
    blocks.each do |s|
      m = s.match re
      return [s, m] if m
    end
    return
  end

  # TODO Fails on Zot Defense + Sprint
  def find_version(blocks)
    return match_one blocks, / Dungeon Crawl Stone Soup version (\S+)/
  end

  def check_if_tiles(blocks)
    interface = match_one blocks, / Dungeon Crawl Stone Soup version \S+ \((\w+)/
    interface != 'console'
  end

  def find_score_char_title(blocks)
    # 178 Snwcln the Vexing (level 3
    _, match = find_in blocks, score_block_re = /\A
      (?<score>\d+)    \s
      (?<character>.*) \s
      the              \s
      (?<title>.*)     \s
      \(level \s \d+
    /x
    return {} if match.nil?
    return {
      :score     => match[:score].to_i,
      :character => match[:character],
      :title     => match[:title],
    }
  end

  def find_race_background(blocks)
    _, rb = find_in blocks, /Began as a #{DCSS.race_background_re}/

    raise ParseFailure, "Couldn't find a race & background!" unless rb
    
    return {
      :race       => rb[:race],
      :background => rb[:background],
    }
  end

  def find_turns_duration(blocks)
    # Snwcln the Vexing (Felid Wanderer)  Turns: 3364, Time: 00:11:02
    # fleugma the Thaumaturge (SEEE)  Turns: 14495, Time: 01:06:50
    _, match = find_in blocks, /
       Turns: \s (?<turns>[\d.]+), \s
       Time:  \s (?<duration>[\d\s:,]+) $
    /x

    return {} if match.nil?

    return {
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
      :start_time       => start_dt,
      :end_time         => end_dt.to_time,
      :duration_seconds => game_in_seconds,
    }
  end
  
  def find_place_god_piety_hunger(sections)
    # XXX Won't match everything yet e.g You were a toy of Xom
    pgp_str, _ = find_in sections, /\AYou escaped|were/

    return {} unless pgp_str

    pgp_res = {
      :place => /^You (?:were [oi]n )?(?<place>[^.]+)[.]/,
      :god   => /You (?:worshipped (?<god>[\s\w]+)[.])|(?:were (?<god>Xom))|(?:.*?(?<god>Xom).$)/,
      # Too lazy to handle Xom weirdness
      :piety => /^[\w\s]+ was (?<piety>[\w\s]+) (?:by your worship|with you)?[.]$/,
      # :hunger => /^You were ((?:not )?hungry|full)/, XXX Worth including?
    }
    
    place_religion = pgp_res.reduce({}) do |pgp, kv|
      key, re = kv
      match   = pgp_str.match re
      match ? pgp.merge({key => match[key]}) : pgp
    end

    # Will be false if the player escaped f.ex.
    if place_religion[:place]
      lvl    = place_religion[:place].match /(\d+)/
      branch = place_religion[:place].match /(#{DCSS.branch_re})/i

      place_religion[:level]  = lvl[0].to_i if lvl
      place_religion[:branch] = branch[0]   if branch
    end

    if place_religion[:god]
      _, place_religion[:standing] = *sections[0].match(/Was \w+ ([\w ]+) of #{place_religion[:god]}/)
      # the Shining One -> The Shining One
      place_religion[:god].sub!(/^(.)/) {|c| c.upcase}
    end
    
    return place_religion
  end

  def find_resistances_slots(blocks, race)
    rEquip, _ = find_in blocks, /\ARes[.]Fire\s+:/;

    return {} if rEquip.nil?

    resistances = {}
    rTot_re   = %r{(?:[+x.]\s)+}
    rMatch_re = %r{
      ([A-Z][A-Za-z. ]+\S) \s*: \s (#{rTot_re})
    }x

    rEquip.scan(rMatch_re) do |r, t|
      t.gsub! /\s+/, ''
      r = DCSS::RESISTANCES_MAP[r]
      resistances[r] = if t.length == 1
                         t == '+' ? 'on' : t == '.' ? 'off' : 'disabled'
                       else # Use fractionals?
                         "%d/%d" % [t.count('+'), t.length]
                       end
    end

    equipped_re = %r{([A-Za-z]) - }                 # Mmm, fixed width records.
    items       = rEquip.split(/\n/).collect{|line| line[37, line.length-1]}

    slot_list = race != 'Octopode' ? DCSS::EQUIPMENT_SLOTS : DCSS::EQUIPMENT_SLOTS_OP
    equipped  = slot_list.length.times.reduce({}) do |slots, idx|
      has_slot, slot = *items[idx].match(equipped_re)
      slots[ DCSS::EQUIPMENT_SLOTS[idx] ] = has_slot ? slot : nil
      slots
    end

    return {
      :resistances => resistances,
      :equipped    => equipped
    }
  end

  # TODO Grab "death notice" from score summary block.
  def find_killer_ending(blocks)
    notes_str, _ = find_in blocks, /\ANotes$/m
    return {} if notes_str.nil?

    notes = notes_str.split(/\n/) # (/\s*[|]\s*/)

    # It seems notes can contain an additional (singular?) line which
    # is delimited by an empty line.
    notes.slice!(notes.length - 2, 2) if notes[-2] =~ /^\s*$/
    # Or maybe there's always an empty line now ;_;
    notes.slice!(notes.length - 1, 1) if notes[-1] =~ /^\s*$/
    
    ret = { :ending => notes[-1].split(/\s*[|]\s*/)[-1].strip } # Last note == ending

    # Only looking for the monster that killed the player, not quits/escapes/etc
    killer = notes_str.match(/(by|to)\s(\san?)?(?<culprit>\w+[()\w '-]*)( poison)?\s*\z/x)
    return ret if killer.nil?
    return ret.merge({
      :killer => killer[:culprit].sub(/^an? /, ''), # Meh, too lazy to make re above DTRT
    })
  end

  def find_kills(sections)
    kills_str, _ = find_in sections, /^Vanquished Creatures/m

    return { :kills => {}, :kill_total => 0, :ghost_kills => [] } if kills_str.nil?

    kills_re = /^\s+(?:(\d+|An?) )?(.*?)(?: \(([^)]+)\))?$/

    # Bleurgh, so much state.
    killed_by  = :player
    kills      = { killed_by => [] }
    kill_total = 0
    gkills     = []

    # A bit suboptimal as kills_str will also include Notes hence "fin".
    kills_str.split("\n").each do |line|
      _, amount, creature, location = *line.match(kills_re)
      vanquisher                    = line.match /^Vanquished Creatures \((?<kb>\w+)/
      total                         = line.match /^(?<t>\d+) creatures vanquished[.]/
      fin                           = line.match /^Notes/
      
      if creature
        amount = 1 if amount.nil? or amount[0] == 'A'

        vanquished = {
          :amount   => amount,
          :creature => creature,
          :location => location,
        }

        kills[killed_by].push vanquished
        gkills.push vanquished.merge({:vanquisher => killed_by}) if creature.match /^The ghost of/
      elsif vanquisher
        killed_by = vanquisher[:kb].to_sym
        kills[killed_by] = []
      elsif total
        kill_total += total[:t].to_i
      elsif fin
        break
      end
    end

    return {
      :kills       => kills,
      :kill_total  => kill_total,
      :ghost_kills => gkills,
    }
  end

  def find_visits(blocks)
    # XXX This is a bit fragile.
    return { :levels_seen => match_one(blocks, /saw (\d+) of its level/).to_i }
  end

  def find_stats(blocks)
    stats, _ = find_in blocks, %r{^HP\s+-?\d+/}

    stat_list = %w{HP AC Str MP EV Int Gold SH Dex}
    stat_res  = stat_list.inject({}) do |h, s|
      h.merge({ s => %r{
        #{s} \s+ (?<#{s.downcase}> -?\d+ (?:/\d+)?) # HP -1/12
         (?: \s+ \( (?<max#{s.downcase}>\d+) \) )? \s+   # (13)
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

  def find_state_abilities_runes(blocks)
    state_etc, _ = find_in blocks, /\A@: /

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

  def find_map(sections)
    # Oddly 'Message History' isn't always preceded by two newlines
    _, map_n_message = find_in sections, /^Message History\n(.*)\z/m
    return map_n_message ? { :map => map_n_message[1] } : {}
  end

  def _clean_desc(desc)
    return nil if desc.strip.empty?
    # XXX A bit buggy e.g for the Necronomicon:
    # WARNING: If fail in an attempt to memorise a spell from this book, the book will lash out at you.
    desc.strip
        .gsub(/^ +(?=\S)/m, '')                # Leading space
        .gsub(/your? /, '')                    # "It affects your", "It lets you"
        .sub(/\(You (\w)/) {|c| '('+$1.upcase} # "(You found it", "(You took it"
  end

  def understand_inventory(sections)
    invt, _ = find_in sections, /^Inventory:$/m

    groups = invt.scan /^([A-Z][\w ]+)$(.*?)(?:(?=^[A-Z])|\z)/m
    return {
      :inventory => groups.reduce({}) do |inventory, g|
        type, slots_block  = g
        slots_block.scan /^ (\w) - (.*?)$(.*?)(?:(?=^ \w -)|\z)/m do |slot, item, desc|
          inventory[slot] = {
            :type => type,
            :item => item,
            :desc => _clean_desc(desc),
          }
        end
        inventory
      end
    }
  end

  def find_skills(blocks)
    skills_str, _ = find_in blocks, /\A\s+Skills:/

    return { :skills => {} } if skills_str.nil?

    skill_matches = skills_str.scan /^ (.) Level ([\d,.]+)(?:\(([\d,.]+)\))? ([\w& ]+)$/m
    return {
      :skills => skill_matches.reduce({}) do |skills, match|
        state, level, boosted_level, skill = match
        skills[skill] = {
          :state         => DCSS::SKILL_STATE[state],
          :level         => level.sub(/,/, '.').to_f, # Handle localization (I guess)
          :boosted_level => ( boosted_level and boosted_level.sub(/,/, '.').to_f ),
        }
        skills
      end
    }
  end

  def find_spells(sections)
    no_spells = "You couldn't memorise any spells."
    spells_str, match = find_in sections, /\A(?:#{no_spells})|(?:You had (?<left>\d+|one) spell levels? left.)/

    # i.e "You couldn't memorise any spells."
    return { :spells_left => 0, :spells_known => [] } if spells_str.nil?

    left_i = match[:left] ? ( match[:left] == 'one' ? 1 : match[:left].to_i ) : 0

    spell_re = %r{^
      (.) \s - \s (['\w]+(?:\s['\w]+)*) \s+ # b - Throw Frost
      (#{DCSS.spell_type_re})     \s+ # Ice/Conj
      ( (?:N/A|[#.]+) )           \s+ # #####..
      (\d+%)                      \s+ # 5%
      (\d)                        \s+ # 2
      ([\w/#.]+)                      # Choko | ##.....
    $}mx
      
    return {
      :spells_left  => left_i,
      :spells_known => spells_str.scan(spell_re).collect do |match|
        slot, name, type, p, fail_rate, level, h = match
        power  = p == 'N/A'        ? p : "%d/%d" % [p.count('#'), p.length]
        hunger = h.match(/^[^#.]/) ? h : "%d/%d" % [h.count('#'), h.length]
        {
          :slot      => slot,
          :name      => name,
          :type      => type.split('/'),
          :power     => power,
          :fail_rate => fail_rate,
          :level     => level.to_i,
          :hunger    => hunger,
        }
      end
    }
  end

  def find_notes(blocks)
    notes_str, _ = find_in blocks, /^Notes$/

    # Slightly ugly regex to drop the "heading".
    lines = notes_str.sub(/(?:^.*?$\s*){3}/m, '').split /\n/
    # Pretty sure notes are always present
    return {
      :notes => lines.collect do |line|
        turn, place, note = line.split('|').collect(&:strip)
        { :turn => turn.to_i, :place => place, :note => note }
      end
    }
  end

  class ParseFailure < StandardError; end

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

