# frozen_string_literal: true
class CalendarPresenter
    def initialize(scheduler)
      @scheduler = scheduler
    end

    def self.interview_daily_display(interview, user_timezone)
      start_time_in_min = interview.start_time_minutes(user_timezone)
      end_time_in_min = interview.end_time_minutes(user_timezone)

      {
        id: interview.id,
        top: (start_time_in_min%60) * 100 / 60,
        height: (end_time_in_min - start_time_in_min)/6,
        text: interview.note
      }
    end

    def daily(day_utc, user_timezone)
      daily_interviews_display = \
        (interviews = @scheduler.day(day_utc, :interviewer, :candidate))
          .inject(Hash.new) do |interviews, interview|
            interviews[interview.start_time_minutes(user_timezone)/60] = CalendarPresenter.interview_daily_display(interview, user_timezone)
            interviews
          end
      return [interviews, daily_interviews_display]
    end

    def self.interview_weekly_display(interview, user_timezone)
      start_time_in_min = interview.start_time_minutes(user_timezone)
      end_time_in_min = interview.end_time_minutes(user_timezone)

      {
        id: interview.id,
        top: (start_time_in_min%60) * 100 / 60,
        height: (end_time_in_min - start_time_in_min)/6,
        text: interview.note.slice(0, 30)
      }
    end

    def weekly(aday_in_week, user_timezone)
      weekly_interviews_display = \
        (weekly_interviews = @scheduler.week(aday_in_week, :interviewer, :candidate))
          .inject(Hash.new {|h,k| h[k] = Hash.new}) do |interviews, interview|
            interview_weekday = interview.start_time.in_time_zone(user_timezone).wday
            interviews[interview.start_time_minutes(user_timezone)/60][interview_weekday] = CalendarPresenter.interview_weekly_display(interview, user_timezone)
            interviews
          end

      monday = aday_in_week.beginning_of_week.in_time_zone(user_timezone)
      week_dates = (0..6).map {|i| monday + i.days}

      return [weekly_interviews, weekly_interviews_display, week_dates]
    end

    def monthly(aday_in_month, user_timezone)
      interviews = @scheduler.month(aday_in_month, :interviewer, :candidate).inject(Hash.new {|h,k| h[k] = []}) do |interviews, interview|
        interviews[interview.start_time.in_time_zone(user_timezone).mday].push(interview)
        interviews
      end

      beginning_day = aday_in_month.in_time_zone(user_timezone).beginning_of_month
      end_day = aday_in_month.in_time_zone(user_timezone).end_of_month
      month_days = (0..35).map do |i|
        if i < beginning_day.wday
          nil
        elsif (d = beginning_day + (i - beginning_day.wday).days) <= end_day
          d
        else
          nil
        end
      end

      [month_days, interviews]
    end

    private def wrap_note(note, start, length)
        return [0, ""] if note.nil?
        
        sliceStr = note.slice(start, length)
        if (last_space_index = sliceStr&.rindex(/\s/) || 0) > 0
            [start + last_space_index, sliceStr.slice(0, last_space_index)]
        else
            [start + length, sliceStr]
        end
    end
end
