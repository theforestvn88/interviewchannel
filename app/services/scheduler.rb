# frozen_string_literal: true
# scheduler of user

class Scheduler
    include LimitPerDay
    include OneAtTheTime
    include Query

    def initialize(user)
        @user = user
    end

    def create_interview(start_time:, end_time:, candidate: nil)
        interview = Interview.new(interviewer: @user, candidate: candidate, start_time: start_time, end_time: end_time)
        validate(interview)

        interview.save if interview.errors.empty?
        interview
    end

    def update_interview(interview, **options)
        raise Interview::ModifyingPolicy unless interview.owner?(@user)

        interview.update(**options)
    end

    def delete_interview(interview)
        raise Interview::ModifyingPolicy unless interview.owner?(@user)
        
        interview.destroy
    end

    def owner?(interview)
        interview.owner?(@user)
    end
end
