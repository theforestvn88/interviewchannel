# frozen_string_literal: true

module CalendarHelper
    def strftime(hours:)
        "%s%s" % [
                    hours <= 12 ? "#{hours < 10 ? '0' : ''}#{hours}" : "#{hours < 22 ? '0' : ''}#{hours - 12}", 
                    hours >= 12 ? " PM" : " AM"
                ]
    end

    def start_time_minutes_since_midnight(interview)
        (interview.start_time.seconds_since_midnight/60).floor
    end

    def end_time_minutes_since_midnight(interview)
        (interview.end_time.seconds_since_midnight/60).floor
    end

    def hour_row(time_in_mins)
        time_in_mins%10 == 0 ? (time_in_mins%60 == 0 ? (time_in_mins/60) : -1) : nil
    end

    def daily_row(time_in_mins)
        return [nil, nil] unless @daily_display

        time_in_mins = time_in_mins % 1440
        interview_display = @daily_display[time_in_mins]
        hour = hour_row(time_in_mins)

        return [interview_display, hour]
    end

    def weekly_hour_row(time_in_mins)
        mod = time_in_mins%60
        mod == 0 ? (time_in_mins/60) : (mod == 1 ? -1 : nil)
    end

    def weekly_row(time_in_mins)
        time_in_mins = time_in_mins % 1440
        week_interviews = @weekly_display[time_in_mins]

        return [week_interviews, hour_row(time_in_mins)]
    end
end
