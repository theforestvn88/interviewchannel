require "test_helper"

class MessagerQueryTest < ActiveSupport::TestCase
  setup do
    Message.destroy_all
    @owner = users(:coder1)
    @message1 = Message.create(user_id: @owner.id, channel: "#Ruby #Js #NodeJs #Android", content: "this is message 1", updated_at: 1.week.ago.utc)
    @message2 = Message.create(user_id: @owner.id, channel: "#Ruby #Rails", content: "this is message 2")
    @message3 = Message.create(user_id: @owner.id, channel: "#Ruby #Rails", content: "this is message 3", updated_at: 1.month.ago.utc)
  end

  test "query by tag recently" do
    assert_equal Messager.new.recently(:rails, :nodejs).count, 2
    assert_equal Messager.new.recently(:rails).count, 1
  end

  test "query recently sent messages of current user" do
    assert_equal Messager.new(@owner).own_by_me.count, 2
  end
end
