require 'hashie'

class PlayersController < ApplicationController
  include ParamsFilter

  before_filter :authenticate_user!, :except => [:index, :show, :search]

  # GET /players
  # GET /players.json
  def index
    # TODO
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @players }
    end
  end

  # GET /players/1
  # GET /players/1.json
  def show
    # Needed for deep link generation.
    @user    = User.find(params[:user_id])

    games   = params_for(Game, params)
    sort_by = sort_by_for(Game, params)

    @player  = Player.find(params[:id])
    @games   = games.for(@player.name).desc(sort_by || :end_time).page params[:page]
    @totals  = Hashie::Mash.new(@player.basic_totals)
    @faves   = @player.favourites

    # Because none isn't a particularly interesting choice.
    @faves[:god].delete 'none'

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

  # respond_to :json
  def search
    @players = Player.where(name: /^#{Regexp::quote(params[:q])}/i)
  end
end
