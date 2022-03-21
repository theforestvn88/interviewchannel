# frozen_string_literal: true
module HomeHelper
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
end
