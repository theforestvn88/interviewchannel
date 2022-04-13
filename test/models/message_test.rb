require "test_helper"

class MessageTest < ActiveSupport::TestCase
  setup do
    @owner = users(:coder1)
    @message1 = Message.create(user_id: @owner.id, channel: "#Ruby #Js #Android", content: "this is message 1", updated_at: 1.week.ago.utc)
    @message2 = Message.create(user_id: @owner.id, channel: "#Ruby #Rails", content: "this is message 2")
  end

  test "query by tags" do
    assert_equal Message.by_tag([:ruby, :rails]).count, 2
    assert_equal Message.by_tag([:js, :rails]).count, 2
    assert_equal Message.by_tag([:js, :android]).count, 1
  end

  test "query by time" do
    assert_equal Message.by_updated_time(1.hour.ago.utc).count, 1
    assert_equal Message.by_updated_time(1.month.ago.utc).count, 2
  end

  test "query by user" do
    assert_equal Message.by_owner(@owner.id).count, 2
    assert_equal Message.by_owner(-1).count, 0
  end
end
