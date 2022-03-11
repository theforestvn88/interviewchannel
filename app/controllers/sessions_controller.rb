# frozen_string_literal: true

class SessionsController < ApplicationController
  def callback
    if request && auth = request.env['omniauth.auth']
      user = User.find_or_create_from_omniauth(auth)
      session[:user_id] = user.id
      redirect_to root_path
    else
      destroy
    end
  end

  def destroy
    reset_session
    redirect_to root_path
  end
end
