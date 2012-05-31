class PlayersController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show]

  # GET /players
  # GET /players.json
  def index
    @user    = User.find(params[:user_id])
    @players = @user.players

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @players }
    end
  end

  # GET /players/1
  # GET /players/1.json
  def show
    @user   = User.find(params[:user_id])
    @player = Player.find(params[:id])
    @games  = @player.games
    faves  = Game.character_favourites(@player.name)
    # XXX There's surely a more elegant approach?
    @race, @background, @god = faves.keys.collect do |type|
      f, c = faves[type].reduce {|fave, pair| pair[1] > fave[1] ? pair : fave}
      { fave: f, count: c.to_i }
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @player }
    end
  end

  # GET /players/new
  # GET /players/new.json
  def new
    @player = Player.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @player }
    end
  end

  # GET /players/1/edit
  def edit
    @player = current_user.players.find(params[:id])
  end

  # POST /players
  # POST /players.json
  def create
    @player = current_user.players.new(params[:player])

    respond_to do |format|
      if @player.save
        format.html { redirect_to [@player.user, @player], notice: 'Player was successfully created.' }
        format.json { render json: @player, status: :created, location: url }
      else
        format.html { render action: "new" }
        format.json { render json: @player.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /players/1
  # PUT /players/1.json
  def update
    @player = Player.find(params[:id])

    respond_to do |format|
      if @player.update_attributes(params[:player])
        format.html { redirect_to [@player.user, @player], notice: 'Player was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @player.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /players/1
  # DELETE /players/1.json
  def destroy
    @player = Player.find(params[:id])
    @player.destroy

    respond_to do |format|
      format.html { redirect_to user_players_url }
      format.json { head :no_content }
    end
  end
end
