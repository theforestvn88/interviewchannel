require "test_helper"

class InterviewTest < ActiveSupport::TestCase
  test "create: validate interviewer existed" do
    user = users(:coder1)
    
    interview1 = Interview.create(candidate: user);
    assert_equal interview1.errors[:interviewer], ["must exist"]

    interview2 = Interview.create(interviewer: user)
    assert_equal interview2.errors[:interviewer], []
  end

  test "query by owner (as interviewer)" do
    interviewer = users(:coder1)
    assert_equal Interview.as_interviewer(interviewer), interviews(:ruby_dev1, :ruby_dev2)
  end

  test "as candidate" do
    candidate = users(:coder2)
    assert_equal Interview.as_candidate(candidate), interviews(:ruby_dev1, :ruby_dev2)
  end

  test "query by time" do
    from_time = interviews(:ruby_dev1).start_time
    to_time = interviews(:ruby_dev2).end_time
    assert_equal Interview.by_time(from_time, to_time), interviews(:ruby_dev1, :ruby_dev2)
    assert_equal Interview.by_time(to_time, DateTime.now), [interviews(:ruby_dev2)]
  end
end
