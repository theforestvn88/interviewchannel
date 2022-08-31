# frozen_string_literal: true

class SessionsController < ApplicationController
  def new
    @social_support = SettingRepo.fetch("social_auth.providers")
    render layout: false
  end

  def create
    begin
      RateLimiter.new(nil, "request_#{request&.ip}_login", 2, nil, expires_in: 1.minute).check!
    rescue RateLimiter::LimitExceeded => e
      head :too_many_requests and return
    end

    if request && auth = request.env['omniauth.auth']
      user = User.find_or_create_by_omniauth(auth)
      unless user.banned?
        user.update(curr_timezone: session["timezone"] || "UTC")
        session[:user_id] = user.id
        
        redirect_to(root_path) and return
      end
    end
      
    reset
  end

  def destroy
    reset
  end

  private def reset
    reset_session
    redirect_to root_path
  end
end
