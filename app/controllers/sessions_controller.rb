class SessionsController < ApplicationController
  def create
    user = User.find_or_create_from_omniauth(request.env["omniauth.auth"])

    if user.persisted?
      session[:user_id] = user.id
      redirect_to root_path, notice: "Signed in as #{user.name}"
    else
      redirect_to root_path, alert: "Authentication failed"
    end
  end

  def destroy
    session.delete(:user_id)
    redirect_to root_path, notice: "Signed out"
  end

  def failure
    redirect_to root_path, alert: "Authentication failed: #{params[:message].humanize}"
  end
end
