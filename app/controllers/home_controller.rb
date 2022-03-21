# frozen_string_literal:true

class HomeController < ApplicationController
  def index
    if user_signed_in?
      @scheduler = Scheduler.new(current_user)
      @presenter = CalendarPresenter.new(@scheduler)
  
      @display = params[:display] || "daily"
      case @display
      when "daily"
        @daily_interviews = @presenter.daily(params[:day])
      when "weekly"
        @weekly_interviews = @presenter.weekly(params[:week])
      when "monthly"
        @month_days, @monthly_interviews = @presenter.monthly(params[:month])
      end
    end
  end

  def week
  end

  def month
  end
end
