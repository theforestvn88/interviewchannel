require "test_helper"

class InterviewTest < ActiveSupport::TestCase
  test "validate interviewer existed" do
    user = User.create(id: 1, name: "coder1", email: "xxx@gmail.com")
    
    interview1 = Interview.create(candidate: user);
    assert_equal interview1.errors[:interviewer], ["must exist"]

    interview2 = Interview.create(interviewer: user)
    assert_equal interview2.errors[:interviewer], []
  end
end
