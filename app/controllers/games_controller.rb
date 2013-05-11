require_dependency 'dcss/coroner'
require_dependency 'collate/game'
require 'open-uri'

class GamesController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show, :update]
  include GamesHelper

  # GET /games
  # GET /games.json
  def index
    games = Collate::Game.new(result_set: Game).filter_and_sort({
        params:       params,
        order:        'desc',
        sort_default: :end_time
      })

    games = games.where(user_id: params[:user_id]) if params[:user_id]

    @current_period = params[:period] || 'alltime'
    unless @current_period == 'alltime'
      m = "last_#{@current_period}".to_sym
      games = Game.respond_to?(m) ? games.send(m) : games.last_week
    end

    @games = games.limit(27).page params[:page]

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @games }
    end
  end

  # GET /games/1
  # GET /games/1.json
  def show
    @game   = Game.find(params[:id])
    @player = @game.player

    respond_to do |format|
      format.html # show.html.erb
      format.json # Leave it to rabl
    end
  end

  def update
    @game = Game.find(params[:id])

    uri    = morgue_uri(@game)
    file   = uri.path.split('/')[-1]
    morgue = DCSS::Coroner.new(open(uri.to_s).read, file).parse

    @game.update_attributes(morgue.merge has_morgue_file: true)
    @game.save!

    # Why doesn't it update the object too?!
    @game = Game.find(params[:id])

    flash[:notice] = "Updated game details from #{uri}"
    render 'show'
  end

  # POST /games
  # POST /games.json
  def create
    # TODO Check it looks like a morgue and not random/malicious junk etc
    morgue_io = params[:game][:morgue]

    @player = current_user.players.find(params[:player])
    morgue = DCSS::Coroner.new(morgue_io.read, morgue_io.original_filename).parse
    morgue[:was_local] = true
    # XXX For key name composition, very DCSS specific
    morgue[:end_time_str] = morgue[:end_time].strftime('%Y%m%d-%H%M%S')
    morgue[:combo]        = DCSS.combo2abbr(morgue[:race], morgue[:background])
    @game = @player.games.new(morgue)

    respond_to do |format|
      # XXX Should handle player errors too I guess.
      if @game.save and @player.save
        format.html { redirect_to @game, notice: 'Game was successfully created.' }
        format.json { render json: @game, status: :created, location: @game }
      else
        format.html { render action: "new" }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /games/1
  # DELETE /games/1.json
  def destroy
    @game = Game.find(params[:id])
    @game.destroy

    respond_to do |format|
      format.html { redirect_to games_url }
      format.json { head :no_content }
    end
  end
end
