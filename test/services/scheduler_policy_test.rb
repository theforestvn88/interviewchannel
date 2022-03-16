require "test_helper"

class SchedulerPolicyTest < ActiveSupport::TestCase
    test "policy: one at the time" do
        scheduler = Scheduler.new(users(:coder1))
        interview1 = scheduler.create_interview(start_time: Time.now.utc, end_time: 1.hour.from_now)
        ok = scheduler.create_interview(start_time: 1.hour.from_now, end_time: 2.hours.from_now)
        overlap = scheduler.create_interview(start_time: 15.minutes.from_now, end_time: 2.hours.from_now)

        assert_equal ok.errors[:time], []
        assert_equal overlap.errors[:time], ["there's other interview overlap time!"]
    end

    test "policy: maximum number of interviews per day per user" do
        scheduler = Scheduler.new(users(:coder1))
        beginToday = Time.now.utc.beginning_of_day
        interview1 = scheduler.create_interview(start_time: beginToday, end_time: beginToday.advance(hours: 1))
        interview2 = scheduler.create_interview(start_time: beginToday.advance(hours: 1, minutes: 1), end_time: beginToday.advance(hours: 2))
        interview3 = scheduler.create_interview(start_time: beginToday.advance(hours: 2, minutes: 1), end_time: beginToday.advance(hours: 3))
        interview4 = scheduler.create_interview(start_time: beginToday.advance(hours: 3, minutes: 1), end_time: beginToday.advance(hours: 4))
        interview5 = scheduler.create_interview(start_time: beginToday.advance(hours: 4, minutes: 1), end_time: beginToday.advance(hours: 5))
        interview6 = scheduler.create_interview(start_time: beginToday.advance(hours: 5, minutes: 1), end_time: beginToday.advance(hours: 6))
        interview7 = scheduler.create_interview(start_time: beginToday.advance(hours: 6, minutes: 1), end_time: beginToday.advance(hours: 7))

        assert_equal interview7.errors[:maximum], ["you created maximum 6 interviews today!"]
    end
end
