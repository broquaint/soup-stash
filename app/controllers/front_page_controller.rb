class FrontPageController < ApplicationController
  def index
    # TODO Restrict by date range when more data is available.
    @games_by_score = Game.desc(:score).page params[:page]
    @games_by_date  = Game.desc(:end_time).limit(5)
    # TODO This will need caching at some level.
    @popular_combos = Game.popular_combos.sort {|a,b| b[:count] <=> a[:count]}.slice(0, 10)
  end
end
