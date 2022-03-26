# frozen_string_literal: true
class CalendarPresenter
    def initialize(scheduler)
        @scheduler = scheduler
    end

    def daily(day)
      @scheduler.day(day, :interviewer, :candidate).inject(Hash.new) do |interviews, interview|
        start_time_minutes = (interview.start_time.seconds_since_midnight/60).floor
        end_time_minutes = (interview.end_time.seconds_since_midnight/60).floor

        interviews[start_time_minutes] = {:part => :start}
        note_count = 0
        (start_time_minutes+10-(start_time_minutes%10)..end_time_minutes-1).step(10) do |t|
          note_count, wrapped_note = wrap_note(interview.note, note_count, 300)
          interviews[t] ||= {:part => :middle, :content => wrapped_note, :id => interview.id}
        end
        interviews[end_time_minutes] ||= {:part => :end}

        interviews
      end
    end

    def weekly(aday_in_week)
      weekly_interviews = \
        @scheduler.week(aday_in_week, :interviewer, :candidate).inject(Hash.new {|h,k| h[k] = Hash.new}) do |interviews, interview|
          interview_weekday = interview.start_time.wday
          start_time_minutes = (interview.start_time.seconds_since_midnight/60).floor
          end_time_minutes = (interview.end_time.seconds_since_midnight/60).floor

          interviews[start_time_minutes][interview_weekday] = {:part => :start}
          note_count = 0
          (start_time_minutes + 10 - start_time_minutes%10..end_time_minutes-1).step(10) do |t|
            note_count, wrapped_note = wrap_note(interview.note, note_count, 30)
            interviews[t][interview_weekday] ||= {:part => :middle, :content => wrapped_note, :id => interview.id}
          end
          interviews[end_time_minutes][interview_weekday] ||= {:part => :end}

          interviews
        end

      monday = aday_in_week.beginning_of_week
      week_dates = (0..6).map {|i| monday + i.days}

      return [weekly_interviews, week_dates]
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
