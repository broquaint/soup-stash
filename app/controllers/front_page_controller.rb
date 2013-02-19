class FrontPageController < ApplicationController
  def index
    opts = params.keys.reduce({}) do |opts, k|
      Game.attribute_method?(k) ? opts.merge(k => params[k]) : opts
    end

    g = Game.last_week
    @games_by_score = g.where(opts).desc(:score).page params[:page]
    @games_by_date  = Game.desc(:end_time).limit(5)
    @popular_combos = Rails.cache.fetch('popular_combos', expires_in: 1.day) do
      g.popular_combos.sort {|a,b| b[:count] <=> a[:count]}.slice(0, 10)
    end
  end
end
