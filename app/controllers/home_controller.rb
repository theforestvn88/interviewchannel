# frozen_string_literal:true

class HomeController < ApplicationController
  before_action :check_logged_in, except: :index
  before_action :ensure_turbo_frame_request, except: :index
  before_action :create_scheduler_and_presenter
  before_action :set_time

  def index
    if user_signed_in?
      @display = params[:display] || "daily"

      case @display
      when "daily"
        @daily_interviews, @daily_display = @presenter.daily(@target_date, current_user.curr_timezone)
      when "weekly"
        @weekly_interviews, @weekly_display, @week_dates = @presenter.weekly(@target_date, current_user.curr_timezone)
      when "monthly"
        @month_days, @monthly_interviews = @presenter.monthly(@target_date, current_user.curr_timezone)
      end
    end
  end

  def daily
    @display = "daily"
    @target_date += params[:shift].to_i.days

    @daily_interviews, @daily_display = @presenter.daily(@target_date, current_user.curr_timezone)
    render partial: "interviews/calendar"
  end

  def weekly
    @display = "weekly"
    @wday = params[:shift].to_i == 0 ? Time.now.in_time_zone(current_user.curr_timezone).wday : -1
    @target_date += params[:shift].to_i.week

    @weekly_interviews, @weekly_display, @week_dates = @presenter.weekly(@target_date, current_user.curr_timezone)
    render partial: "interviews/calendar"
  end

  def monthly
    @display = "monthly"
    @mday = params[:shift].to_i == 0 ? Time.now.mday : -1
    @target_date += params[:shift].to_i.month
    
    @month_days, @monthly_interviews = @presenter.monthly(@target_date, current_user.curr_timezone)
    render partial: "interviews/calendar"
  end

  private def create_scheduler_and_presenter
    if user_signed_in?
      @scheduler = Scheduler.new(current_user)
      @presenter = CalendarPresenter.new(@scheduler)
    end
  end

  private def set_time
    @target_date = begin
      DateTime.parse(params[:date])
    rescue => e
      Time.now.in_time_zone(current_user&.curr_timezone || "UTC")
    end

    @tz_offset = ActiveSupport::TimeZone[current_user.curr_timezone].formatted_offset if user_signed_in?
  end

  private def check_logged_in
    redirect_to root_path unless user_signed_in?
  end
end
