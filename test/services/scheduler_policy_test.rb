require "test_helper"

class SchedulerPolicyTest < ActiveSupport::TestCase
    teardown do
        Interview.destroy_all
    end

    test "creating policy: one at the time" do
        scheduler = Scheduler.new(users(:coder1))
        interview1 = scheduler.create_interview(start_time: Time.now.utc, end_time: 1.hour.from_now)
        ok = scheduler.create_interview(start_time: 1.hour.from_now, end_time: 2.hours.from_now)
        overlap = scheduler.create_interview(start_time: 15.minutes.from_now, end_time: 2.hours.from_now)

        assert_equal ok.errors[:time], []
        assert_equal overlap.errors[:time], ["there's other interview overlap time!"]
    end

    test "creating policy: maximum number of interviews per day per user" do
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

    test "modifying policy: only owner (interviewer) could update/delete the interview" do
        scheduler1 = Scheduler.new(users(:coder1))
        scheduler2 = Scheduler.new(users(:coder2))
        interview1 = scheduler1.create_interview(start_time: Time.now.utc, end_time: 1.hour.from_now).tap(&:save)
        interview2 = scheduler2.create_interview(start_time: Time.now.utc, end_time: 1.hour.from_now).tap(&:save)

        assert_raises Interview::ModifyingPolicy do
            scheduler1.update_interview(interview2, start_time: 2.hours.from_now, end_time: 3.hours.from_now)
        end

        assert_raises Interview::ModifyingPolicy do
            scheduler2.delete_interview(interview1)
        end

        assert_nothing_raised do
            old_start_time = interview1.start_time
            scheduler1.update_interview(interview1, start_time: 2.hours.from_now, end_time: 3.hours.from_now)
            assert_not_equal Interview.find(interview1.id).start_time, old_start_time
        end

        assert_nothing_raised do
            assert_equal Interview.find_by(id: interview2.id), interview2
            scheduler2.delete_interview(interview2)
            assert_nil Interview.find_by(id: interview2.id)
        end
    end
end
