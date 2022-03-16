# frozen_string_literal: true
# policy: do not allow user's interviews overlap (time)
class Scheduler
    module OneAtTheTime
        def validate(interview)
            time_range = interview.start_time..interview.end_time
            overlap = as_role(:interviewer).where(start_time: time_range).or(Interview.where(end_time: time_range))
            unless overlap.empty?
                interview.errors.add("time", "there's other interview overlap time!")
                return
            end

            super(interview) if defined?(super)
        end
    end
end