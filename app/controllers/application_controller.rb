# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  rescue_from ActionController::InvalidAuthenticityToken do |exception|
    destroy
  end

  helper_method :current_user, :user_signed_in?
  
  private

    def current_user
      return unless session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
      @current_user.session_timezone = session["timezone"] || "UTC"
      @current_user
    end

    def user_signed_in?
      !!current_user
    end

    private def ensure_turbo_frame_request
      redirect_to root_path unless turbo_frame_request?
    end
end

