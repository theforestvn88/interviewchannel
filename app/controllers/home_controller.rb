# frozen_string_literal:true

class HomeController < ApplicationController
  before_action :check_logged_in, except: :index
  before_action :create_scheduler_and_presenter
  before_action :get_target_date

  def index
    if user_signed_in? 
      @display = params[:display] || "daily"
      case @display
      when "daily"
        @daily_interviews = @presenter.daily(@target_date)
      when "weekly"
        @weekly_interviews = @presenter.weekly(@target_date)
      when "monthly"
        @month_days, @monthly_interviews = @presenter.monthly(@target_date)
      end
    end
  end

  def daily
    @display = "daily"
    @target_date += params[:shift].to_i.days
    @daily_interviews = @presenter.daily(@target_date)

    render partial: "interviews/calendar"
  end

  def weekly
    @display = "weekly"
    @wday = params[:shift].to_i == 0 ? Time.now.wday : -1
    @target_date += params[:shift].to_i.week
    @weekly_interviews = @presenter.weekly(@target_date)
    render partial: "interviews/calendar"
  end

  def monthly
    @display = "monthly"
    @mday = params[:shift].to_i == 0 ? Time.now.mday : -1
    @target_date += params[:shift].to_i.month
    @month_days, @monthly_interviews = @presenter.monthly(@target_date)
    render partial: "interviews/calendar"
  end

  private def create_scheduler_and_presenter
    if user_signed_in?
      @scheduler = Scheduler.new(current_user)
      @presenter = CalendarPresenter.new(@scheduler)
    end
  end

  private def get_target_date
    @target_date = begin
      Date.parse(params[:date])
    rescue
      Time.now
    end
  end

  private def check_logged_in
    redirect_to root_path unless user_signed_in?
  end
end
