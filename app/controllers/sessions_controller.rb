# frozen_string_literal: true

class SessionsController < ApplicationController
  def new
    render layout: false
  end

  def create
    if request && auth = request.env['omniauth.auth']
      user = User.find_or_create_by_omniauth(auth)
      user.set_session_timezone(session["timezone"])
      session[:user_id] = user.id
      
      redirect_to root_path
    else
      reset
    end
  end

  def destroy
    reset
  end

  private def reset
    reset_session
    redirect_to root_path
  end
end
