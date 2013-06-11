class SoupStash  
  class Ingestlogfile
    class Transformer
      def initialize
        @existing = [:dex, :hp, :game_type, :god, :gold, :int, :killer, :race, :str, :title, :xl]

        @from_to = {
          "absdepth"  => :deepest_level,
          "ckaux"     => :killer_weapon,
          "dam"       => :damage,
          "goldfound" => :gold_found,
          "goldspent" => :gold_spent,
          "ikiller"   => :invocant_killer,
          "kaux"      => :killer_weapon_desc,
          "ktyp"      => :killer_type,
          "sdam"      => :source_damage,
          "sk"        => :skill,
          "sklev"     => :skill_level,
          "src"       => :server,
          "tdam"      => :turn_damage,
          "tmsg"      => :terse_ending,

          "br"        => :branch,
          "char"      => :combo,
          "cls"       => :background,
          "cv"        => :version,
          "dur"       => :duration,
          "end"       => :end_time,
          "game_type" => :name,
          "kills"     => :kill_total,
          "lvl"       => :level,
          "map"       => :map_name,
          "mhp"       => :maxhp,
          "mmhp"      => :maxmaxhp,
          "name"      => :character,
          "place"     => :place_abbr,
          "sc"        => :score,
          "start"     => :start_time,
          "turn"      => :turns,
          "v"         => :full_version,
          "vmsg"      => :ending,
        }

        @transforms = {
          :splat      => lambda {|v| v && v.length != 0},
          :tiles      => lambda {|v| v == 'y'},
          :branch     => lambda {|v| DCSS.branch_for_abbr(v)},
          :character  => lambda {|v| v.to_s}, # JSON/Perl can produce non-strings.
          :end_time   => lambda {|v| time_str_to_object(v.to_s)},
          :start_time => lambda {|v| time_str_to_object(v.to_s)},
        }
      end

      def time_str_to_object(str)
        m  = str.match /(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})/
        dt = DateTime.new *m.captures.collect(&:to_i)
        return dt.to_time
      end

      def logfile_to_model(log_game, source)
        game = @existing.reduce({}) {|g, k| g.merge k => log_game[k.to_s]}
        @from_to.each    {|from, to| game[to] = log_game[from]}
        @transforms.each {|k, trans| game[k]  = trans.call(game.has_key?(k) ? game[k] : log_game[k.to_s])}

        game.merge({
            :won           => 0 == ( game[:ending] =~ /^escaped with the Orb/i ),
            :end_time_str  => game[:end_time].strftime('%Y%m%d-%H%M%S'),
            :from_log_file => true,
            :version       => DCSS.full_version_to_major_version(game[:full_version]),
            :server        => source, # Assume we have a useful URI string.
          })
      end
    end
  end
end
