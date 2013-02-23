require 'dcss/coroner'

require 'yaml'
# require 'pp'

# "I'm sorry, Dave. I'm afraid I can't do that."
require 'devise' # needed by User
require "./config/initializers/devise.rb"
require 'kaminari' # needed by Player & Game models which User drags in
Kaminari::Hooks.init # kaminari/railtie.rb

require 'mongoid'
Mongoid.load!("./config/mongoid.yml", :development)

$LOAD_PATH.unshift './app'
require 'models/user'
require 'models/player'
require 'models/game'

# require 'soupstash'
# TODO - Stick this in a namespace or something.
class IngestLogfile
  class Transformer
    def initialize
      @existing = [:dex, :hp, :game_type, :god, :gold, :int, :killer, :race, :str, :title, :xl]

      @from_to = {
        "absdepth"  => :deepest_level,
        "ckaux"     => :killer_weapon,
        "dam"	  => :damage,
        "goldfound" => :gold_found,
        "goldspent" => :gold_spent,
        "ikiller"   => :invocant_killer,
        "kaux"      => :killer_weapon_desc,
        "ktyp"      => :killer_type,
        "sdam"      => :source_damage,
        "sk"	  => :skill,
        "sklev"     => :skill_level,
        "src"	  => :server,
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
        "mhp"	  => :maxhp,
        "mmhp"      => :maxmaxhp,
        "name"      => :character,
        "place"     => :place_abbr,
        "sc"	  => :score,
        "start"     => :start_time,
        "turn"      => :turns,
        "v"	  => :version,
        "vmsg"      => :ending,
      }

      @transforms = {
        :splat      => lambda {|v| v && v.length != 0},
        :tiles      => lambda {|v| v == 'y'},
        :branch     => lambda {|v| DCSS::BRANCHES[v]},
        :character  => lambda {|v| v.to_s}, # YAML/Perl can produce non-strings.
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
      @transforms.each {|k, trans| game[k]  = trans.call(game[k])}

      game.merge({
                   :end_time_str  => game[:end_time].strftime('%Y%m%d-%H%M%S'),
                   :from_log_file => true,
                   :server        => source, # Assume we have a useful URI string.
                 })
    end
  end

  class Parser
    def initialize
      @parsed_count = 0

      perl_in, @log_out  = IO.pipe
      @yaml_in, perl_out = IO.pipe

      @pid = fork {
        parser_path = Dir.getwd + '/script/logfile-parser.pl'

        Dir::chdir './vendor/dcss_henzell'

        $stdin.reopen  perl_in
        $stdout.reopen perl_out 

        @yaml_in.close
        @log_out.close

        # Use whatever perl happens to be in the path rather than hard coding in she-bang.
        # TODO Pass in $server and any other relevant log fields data.
        exec 'perl', parser_path
      }

      perl_in.close
      perl_out.close
    end

    def import_from(logfile)
      $stdout.sync
      logfile.each do |line|
        @log_out.puts line

        yaml = ''
        yaml += line while '__EOF__' != (line = @yaml_in.gets).chomp
        game = YAML::load yaml

        yield game

        $stdout.print "At line #{@parsed_count}\r"
        @parsed_count += 1
      end
    end

    def finish_parsing
      begin
        @log_out.puts '__EXIT__'
      rescue Errno::EPIPE
      end

      Process.waitpid(@pid)

      puts "Imported #{@parsed_count} games!"
    end
  end

  def parser
    Parser.new
  end

  # A utility class to simplify keeping track of state.
  require 'soupstash/ingestlogfile/offsetstate'
  def offset_state
    OffsetState.new(@source)
  end

  attr_reader :players
  def initialize(source)
    @source      = source
    init_user
    @players     = {}
    @transformer = Transformer.new
  end

  def init_user
    @user_id = 'unclaimed'
    begin
      # XXX Learn more devise and/or rails to desuck this.
      User.create!(
                   :email => "empty@example.com",
                   :password => 'password',
                   :password_confirmation => 'password',
                   :name => @user_id
                   )
    rescue Mongoid::Errors::Validations => e
      "User already exists, moving on with life."
    end
  end

  def player_id_for(game)
    c = game[:character].to_s
    return @players[c].id if @players.key? c

    p = Player.create(:name => c, :for_game => game[:game_type], user_id: @user_id)
    @players[c] = p

    p.id
  end

  def commit_game(game)
    for_model = @transformer.logfile_to_model(game, @source)
    for_model.merge!(:player_id => player_id_for(for_model))
    Game.create!(for_model)
  end
end
