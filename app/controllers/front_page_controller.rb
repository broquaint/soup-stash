class FrontPageController < ApplicationController
  include ParamsFilter
  
  def index
    @current_period = params[:period] || 'week'
    games = if @current_period != 'alltime'
      m = "last_#{@current_period}".to_sym
      Game.respond_to?(m) ? Game.send(m) : Game.last_week
    else
      Game
    end

    popular_combos = Rails.cache.fetch("popular_combos_#{@current_period}}", expires_in: 1.day) do
      games.popular_combos.sort {|a,b| b[:count] <=> a[:count]}
    end
    @most_pop_combos  = popular_combos.slice(0, 10)
    @least_pop_combos = popular_combos.slice(-10, popular_combos.length).reverse

    @games_by_score = params_for(games, params).desc(:score).page params[:page]
    @games_by_date  = Game.desc(:end_time).limit(5)
  end
end
