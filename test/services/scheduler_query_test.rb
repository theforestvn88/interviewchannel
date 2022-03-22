require "test_helper"

class SchedulerQueryTest < ActiveSupport::TestCase
  setup do
    Interview.destroy_all
  end

  test "calendar: today" do
    ruby_today = Interview.create!(interviewer: users(:coder1), start_time: Time.now.utc, end_time: 1.hour.from_now.utc)
    assert_equal Scheduler.new(users(:coder1)).today(:interviewer, :candidate), [ruby_today]
  end

  test "calendar: this week" do
    ruby_today = Interview.create(interviewer: users(:coder1), start_time: Time.now.utc, end_time: 1.hour.from_now.utc)
    ruby_thisweek = Interview.create(interviewer: users(:coder1), start_time: Time.now.utc.beginning_of_week, end_time: Time.now.utc.beginning_of_week)
    assert_equal Scheduler.new(users(:coder1)).this_week(:interviewer, :candidate), [ruby_today, ruby_thisweek]
  end

  test "calendar: this month" do
    ruby_today = Interview.create(interviewer: users(:coder1), start_time: Time.now.utc, end_time: 1.hour.from_now.utc)
    ruby_thisweek = Interview.create(interviewer: users(:coder1), start_time: Time.now.utc.beginning_of_week, end_time: Time.now.utc.beginning_of_week)
    ruby_thismonth = Interview.create(interviewer: users(:coder1), start_time: Time.now.utc.beginning_of_month, end_time: Time.now.utc.beginning_of_month)
    assert_equal Scheduler.new(users(:coder1)).this_month(:interviewer, :candidate), [ruby_today, ruby_thisweek, ruby_thismonth]
  end

  test "calendar: prev day" do
    ruby_yesterday = Interview.create!(interviewer: users(:coder1), start_time: 1.day.ago.utc, end_time: 1.day.ago.utc)
    assert_equal Scheduler.new(users(:coder1)).previous_day(Time.now.utc, :interviewer, :candidate), [ruby_yesterday]
  end

  test "calendar: prev week" do
    ruby_prev_week = Interview.create!(interviewer: users(:coder1), start_time: 1.week.ago.utc, end_time: 1.week.ago.utc)
    assert_equal Scheduler.new(users(:coder1)).previous_week(Time.now.utc, :interviewer, :candidate), [ruby_prev_week]
  end

  test "calendar: prev month" do
    ruby_prev_month = Interview.create!(interviewer: users(:coder1), start_time: 1.month.ago.utc, end_time: 1.month.ago.utc)
    assert_equal Scheduler.new(users(:coder1)).previous_month(Time.now.utc, :interviewer, :candidate), [ruby_prev_month]
  end

  test "calendar: next day" do
    ruby_tomorrow = Interview.create!(interviewer: users(:coder1), start_time: 1.day.from_now.utc, end_time: 1.day.from_now.utc)
    assert_equal Scheduler.new(users(:coder1)).next_day(Time.now.utc, :interviewer, :candidate), [ruby_tomorrow]
  end

  test "calendar: next week" do
    ruby_next_week = Interview.create!(interviewer: users(:coder1), start_time: 1.week.from_now.utc, end_time: 1.week.from_now.utc)
    assert_equal Scheduler.new(users(:coder1)).next_week(Time.now.utc, :interviewer, :candidate), [ruby_next_week]
  end

  test "calendar: next month" do
    ruby_next_month = Interview.create!(interviewer: users(:coder1), start_time: 1.month.from_now.utc, end_time: 1.month.from_now.utc)
    assert_equal Scheduler.new(users(:coder1)).next_month(Time.now.utc, :interviewer, :candidate), [ruby_next_month]
  end

  test "filter by keyword" do
    ruby_today = Interview.create(interviewer: users(:coder1), candidate: users(:coder2), start_time: Time.now.utc, end_time: 1.hour.from_now.utc)
    ruby_thisweek = Interview.create(interviewer: users(:coder1), note: "junior", start_time: Time.now.utc.beginning_of_week, end_time: Time.now.utc.beginning_of_week)
    ruby_thismonth = Interview.create(interviewer: users(:coder1), note: "senior", start_time: Time.now.utc.beginning_of_month, end_time: Time.now.utc.beginning_of_month)
    assert_equal Scheduler.new(users(:coder1)).this_month(:interviewer, :candidate, keyword: "Coder2"), [ruby_today]
    assert_equal Scheduler.new(users(:coder1)).this_month(:interviewer, :candidate, keyword: "junior"), [ruby_thisweek]
    assert_equal Scheduler.new(users(:coder1)).this_month(:interviewer, :candidate, keyword: "senior"), [ruby_thismonth]
    assert_equal Scheduler.new(users(:coder2)).this_month(:interviewer, :candidate, keyword: "Coder1"), [ruby_today]
    assert_equal Scheduler.new(users(:coder2)).this_month(:interviewer, :candidate, keyword: "junior"), []
    assert_equal Scheduler.new(users(:coder2)).this_month(:interviewer, :candidate, keyword: "senior"), []
  end
end
