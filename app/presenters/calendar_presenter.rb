# frozen_string_literal: true
class CalendarPresenter
    def initialize(scheduler)
        @scheduler = scheduler
    end

    def daily(day)
        @scheduler.today(:interviewer, :candidate).inject(Hash.new) do |interviews, interview|
            start_time_minutes = (interview.start_time.seconds_since_midnight/60).floor
            interviews[start_time_minutes] = [:start, :red, "#{interview.start_time.strftime("%I:%M %p")} -> #{interview.end_time.strftime("%I:%M %p")}"]
            end_time_minutes = (interview.end_time.seconds_since_midnight/60).floor
            note_count = 0
            (start_time_minutes+1..end_time_minutes-1).each do |t|
              note_count, wrapped_note = wrap_note(interview.note, note_count, 300)
              interviews[t] ||= [:middle, :red, wrapped_note]
            end
            interviews[end_time_minutes] ||= [:end, :red, nil]
  
            interviews
        end
    end

    def weekly(week)
        @scheduler.this_week(:interviewer, :candidate).inject(Hash.new {|h,k| h[k] = Hash.new}) do |interviews, interview|
            start_time_minutes = (interview.start_time.seconds_since_midnight/60).floor
            interview_weekday = interview.start_time.wday
            
            interviews[start_time_minutes][interview_weekday] = [:start, :red, "#{interview.start_time.strftime("%I:%M %p")} -> #{interview.end_time.strftime("%I:%M %p")}"]
            end_time_minutes = (interview.end_time.seconds_since_midnight/60).floor
            note_count = 0
            (start_time_minutes+1..end_time_minutes-1).each do |t|
              note_count, wrapped_note = wrap_note(interview.note, note_count, 30)
              interviews[t][interview_weekday] ||= [:middle, :red, wrapped_note]
            end
            interviews[end_time_minutes][interview_weekday] ||= [:end, :red, nil]
  
            interviews
        end
    end

    def monthly(month)
        interviews = @scheduler.this_month(:interviewer, :candidate).inject(Hash.new {|h,k| h[k] = []}) do |interviews, interview|
            interviews[interview.start_time.mday].push(interview)
            interviews
        end

        beginning_day = Time.now.beginning_of_month
        end_day = Time.now.end_of_month
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
        sliceStr = note.slice(start, length)
        if (last_space_index = sliceStr&.rindex(/\s/) || 0) > 0
            [start + last_space_index, sliceStr.slice(0, last_space_index)]
        else
            [start + length, sliceStr]
        end
    end
end
