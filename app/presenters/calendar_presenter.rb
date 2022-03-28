# frozen_string_literal: true
class CalendarPresenter
    def initialize(scheduler)
        @scheduler = scheduler
    end

    def self.interview_daily_display(interview)
      {
        id: interview.id,
        top: (interview.start_time_minutes%60) * 100 / 60,
        height: (interview.end_time_minutes - interview.start_time_minutes)/6,
        text: interview.note + " (" +  "#{interview.start_time.strftime('%R')} -> #{interview.end_time.strftime('%R')}" + ")"
      }
    end

    def daily(day)
      daily_interviews_display = \
        (interviews = @scheduler.day(day, :interviewer, :candidate))
          .inject(Hash.new) do |interviews, interview|
            interviews[interview.start_time_minutes/60] = CalendarPresenter.interview_daily_display(interview)
            interviews
          end
      return [interviews, daily_interviews_display]
    end

    def self.interview_weekly_display(interview)
      {
        id: interview.id,
        top: (interview.start_time_minutes%60) * 100 / 60,
        height: (interview.end_time_minutes - interview.start_time_minutes)/6,
        text: interview.note.slice(0, 30)
      }
    end

    def weekly(aday_in_week)
      weekly_interviews_display = \
        (weekly_interviews = @scheduler.week(aday_in_week, :interviewer, :candidate))
          .inject(Hash.new {|h,k| h[k] = Hash.new}) do |interviews, interview|
            interview_weekday = interview.start_time.wday
            interviews[interview.start_time_minutes/60][interview_weekday] = CalendarPresenter.interview_weekly_display(interview)
            interviews
          end

      monday = aday_in_week.beginning_of_week
      week_dates = (0..6).map {|i| monday + i.days}

      return [weekly_interviews, weekly_interviews_display, week_dates]
    end

    def monthly(aday_in_month)
        interviews = @scheduler.month(aday_in_month, :interviewer, :candidate).inject(Hash.new {|h,k| h[k] = []}) do |interviews, interview|
            interviews[interview.start_time.mday].push(interview)
            interviews
        end

        beginning_day = aday_in_month.beginning_of_month
        end_day = aday_in_month.end_of_month
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
