require_dependency 'coroner'

class GamesController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show]

  # GET /games
  # GET /games.json
  def index
    @games = Game.desc(:score).limit(27)
    @games = @games.where({:user_id => params[:user_id]}) if params[:user_id]

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
      format.json { render json: @game }
    end
  end

  # GET /games/new
  # GET /games/new.json
  def new
    @game    = Game.new
    @players = current_user.players

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @game }
    end
  end

  # GET /games/1/edit
  def edit
    @game = Game.find(params[:id])
  end

  # POST /games
  # POST /games.json
  def create
    # TODO Check it looks like a morgue and not random/malicious junk etc
    morgue_io = params[:game][:morgue]

    @player = current_user.players.find(params[:player])
    morgue = Coroner.new(morgue_io.read, morgue_io.original_filename).parse
    morgue[:was_local] = true
    @game = @player.games.new(morgue)

    respond_to do |format|
      if @game.save
        format.html { redirect_to @game, notice: 'Game was successfully created.' }
        format.json { render json: @game, status: :created, location: @game }
      else
        format.html { render action: "new" }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /games/1
  # PUT /games/1.json
  def update
    @game = Game.find(params[:id])

    respond_to do |format|
      if @game.update_attributes(params[:game])
        format.html { redirect_to @game, notice: 'Game was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
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