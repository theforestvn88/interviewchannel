# frozen_string_literal: true
# policy: maximum num of interview could create / per day / per user
class Scheduler
    module LimitPerDay
        MAXIMUM = 6 # TODO: config

        def validate(interview)
            num_interview_today = today(:interviewer).count
            if num_interview_today >= MAXIMUM
                interview.errors.add("maximum", "you created maximum #{MAXIMUM} interviews today!")
                return
            end

            super(interview) if defined?(super)
        end
    end
end
