class FrontPageController < ApplicationController
  def index
    opts = params.keys.reduce({}) do |opts, k|
      Game.attribute_method?(k) ? opts.merge(k => params[k]) : opts
    end

    @current_period = params[:period] || 'week'
    g = if @current_period == 'alltime'
          Game
        else
          m = "last_#{@current_period}".to_sym
          Game.respond_to?(m) ? Game.send(m) : Game.last_week
        end

    @games_by_score = g.where(opts).desc(:score).page params[:page]
    @games_by_date  = Game.desc(:end_time).limit(5)
    @popular_combos = Rails.cache.fetch("popular_combos_#{@current_period}}", expires_in: 1.day) do
      g.popular_combos.sort {|a,b| b[:count] <=> a[:count]}.slice(0, 10)
    end
  end
end
