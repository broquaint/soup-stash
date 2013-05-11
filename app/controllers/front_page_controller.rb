require_dependency 'collate/game'

class FrontPageController < ApplicationController
  def index
    @current_period = params[:period] || 'week'
    games = if @current_period != 'alltime'
      m = "last_#{@current_period}".to_sym
      Game.respond_to?(m) ? Game.send(m) : Game.last_week
    else
      Game
    end

    popular_combos = Rails.cache.fetch("popular_combos_#{@current_period}", expires_in: 1.day) do
      games.popular_combos.sort {|a,b| b[:count] <=> a[:count]}
    end
    @most_pop_combos  = popular_combos.slice(0, 10)
    @least_pop_combos = least_popular_combos(popular_combos)

    some_games = Collate::Game.new(result_set: games)
    @games_by_score = some_games.query_with(params).desc(:score).page params[:page]
    @games_by_date  = Game.desc(:end_time).limit(5)
  end

  private

  def least_popular_combos(combos)
    return [] if combos.empty?
    
    smallest_amount      = combos[-1][:count]
    ascending_popularity = combos.reverse

    least_popular = ascending_popularity.take_while do |combo|
      combo[:count] == smallest_amount
    end

    if least_popular.length < 10
      ascending_popularity.slice(0, 10)
    else
      least_popular.sort {|a,b| a[:race] <=> b[:race]}
    end
  end
end
