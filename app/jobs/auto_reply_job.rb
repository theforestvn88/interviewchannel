class AutoReplyJob < ApplicationJob
  queue_as :default

  def perform(user_id, applying_id, message_id)
    user = User.find(user_id)
    message = Message.find(message_id)

    if message.auto_reply_enable?
      applying = Applying.find(applying_id)
      if applying.replies.count == 0
        reply = Reply.create!(applying_id: applying_id, user_id: user.id, content: message.auto_reply)
        messager = Messager.new(user, user.curr_timezone)
        messager.send_private_reply(applying, reply, locals: {timezone: user.curr_timezone})
      end
    end
  end
end
