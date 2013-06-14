require 'json'

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
module SoupStash
  class IngestLogfile

    require 'dcss/coroner'
    require 'soupstash/ingestlogfile/transformer'
    require 'soupstash/ingestlogfile/parser'

    attr_reader :players
    def initialize
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

      return @players[c].id if @players.has_key? c

      p = Player.create(:name => c, :for_game => game[:game_type], :user_id => @user_id)
      @players[c] = p

      p.id
    end

    def commit_game(game, source)
      for_model = @transformer.logfile_to_model(game, source)
      for_model.merge!(:player_id => player_id_for(for_model))
      Game.create!(for_model)
    end
  end
end
