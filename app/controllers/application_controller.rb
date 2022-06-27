# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  rescue_from ActionController::InvalidAuthenticityToken do |exception|
    destroy
  end

  helper_method :current_user, :user_signed_in?

  before_action :setup_messager
  
  private

    def current_user
      return unless session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
    end

    def user_signed_in?
      !!current_user
    end

    def require_user_signed_in
      redirect_to root_path unless user_signed_in?
    end

    def ensure_user_signed_in
      redirect_to sign_in_path unless user_signed_in?
    end

    def ensure_turbo_frame_request
      redirect_to root_path unless turbo_frame_request?
    end

    def render_not_found
      render :file => "#{Rails.root}/public/404.html", :status => 404
    end

    def setup_messager
      @messager ||= Messager.new(current_user, current_user&.curr_timezone)
      @private_channel ||= @messager.private_channel
    end
end

