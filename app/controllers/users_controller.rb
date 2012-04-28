class UsersController < ApplicationController
  # Don't really want this for show
  before_filter :authenticate_user!

  def show
    @user = User.find(params[:id])
  end
end
