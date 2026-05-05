class HomeController < ApplicationController
  def index
    redirect_to recipes_path if logged_in?
  end
end
