# frozen_string_literal:true

class HomeController < ApplicationController
  before_action :require_user_signed_in, except: :index
  before_action :ensure_turbo_frame_request, except: [:index, :calendar]
  before_action :create_scheduler_and_presenter
  before_action :set_time
  before_action :set_mini_cal_time, only: [:index, :mini_calendar]

  def index
    # messages
    messager = Messager.new
    @messages = messager.recently("#all")
    @next_offset = @messages.last&.updated_at

    if user_signed_in?
      @tags = (current_user.watch_tags || "").split(" ").map { |tag|
        _tag = tag.strip.downcase
        [_tag, messager.count_by_tag(_tag)]
      }.unshift(["#all", messager.count_all])
      @private_channel = messager.private_channel(current_user)
    end
  end

  def mini_calendar
    render partial: "interviews/mini_calendar"
  end

  def calendar
    @display = params[:display] || "daily"

    case @display
    when "daily"
      @daily_interviews, @daily_display = @presenter.daily(@target_date, current_user.curr_timezone)
    when "weekly"
      @weekly_interviews, @weekly_display, @week_dates = @presenter.weekly(@target_date, current_user.curr_timezone)
    when "monthly"
      @monthly_interviews, @monthly_display, @month_days = @presenter.monthly(@target_date, current_user.curr_timezone)
    end

    respond_to do |format|
      format.html { }
      format.json { }
      format.turbo_stream { }
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
    
    @monthly_interviews, @monthly_display, @month_days = @presenter.monthly(@target_date, current_user.curr_timezone)
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

  private def set_mini_cal_time
    return unless user_signed_in?

    @today = Time.now.in_time_zone(current_user&.curr_timezone).beginning_of_day
    @dmonths = [@today, @today.next_month.beginning_of_month, @today.next_month(2).beginning_of_month]
    @selected_date = @target_date.beginning_of_day

    @month_days = @presenter.mini_month(@selected_date)
  end
end
