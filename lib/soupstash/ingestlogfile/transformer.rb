module SoupStash  
  class IngestLogfile
    class Transformer
      EXISTING = [:dex, :hp, :game_type, :god, :gold, :int, :killer, :race, :str, :title, :xl]

      FROM_TO = {
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

      TRANSFORMS = {
        :splat      => lambda {|v| v && v.length != 0},
        :tiles      => lambda {|v| v == 'y'},
        :branch     => lambda {|v| DCSS.branch_for_abbr(v)},
        :character  => lambda {|v| v.to_s}, # JSON/Perl can produce non-strings.
        :end_time   => lambda {|v| time_str_to_object(v.to_s)},
        :start_time => lambda {|v| time_str_to_object(v.to_s)},
      }

      def self.reverse_mapping
        map = {}
        FROM_TO.invert.each{|k, v| map[k.to_s] = v.to_s}
        EXISTING.each{|f| map[f.to_s] = f.to_s}
        return map
      end

      def self.game_hash_to_logfile_hash(game)
        rmap = reverse_mapping
        lg   = rmap.keys.reduce({}) do |r,k|
          v = game[k].is_a?(Time) ? object_to_time_str(game[k]) : game[k].to_s
          game.key?(k) ? r.merge(rmap[k] => v) : r
        end
        
        lg['src'] = DCSS.abbr_for_host(lg['src']).downcase

        return lg
      end

      def self.object_to_time_str(object)
        return object.strftime('%Y%m%d%H%M%S')
      end

      def time_str_to_object(str)
        m  = str.match /(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})/
        dt = DateTime.new *m.captures.collect(&:to_i)
        return dt.to_time
      end

      def logfile_to_model(log_game, source)
        game = EXISTING.reduce({}) {|g, k| g.merge k => log_game[k.to_s]}
        FROM_TO.each    {|from, to| game[to] = log_game[from]}
        TRANSFORMS.each {|k, trans| game[k]  = trans.call(game.has_key?(k) ? game[k] : log_game[k.to_s])}

        game.merge({
            :won           => 0 == ( game[:ending] =~ /^escaped with the Orb/i ),
            :end_time_str  => Transformer.object_to_time_str(game[:end_time]),
            :from_log_file => true,
            :version       => DCSS.full_version_to_major_version(game[:full_version]),
            :server        => source, # Assume we have a useful URI string.
          })
      end
    end
  end
end
