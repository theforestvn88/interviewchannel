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
end
