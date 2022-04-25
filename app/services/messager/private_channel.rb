# frozen_string_literal: true

class Messager
    module PrivateChannel
        def private_channel(user = current_user)
            return nil if user.nil?

            private_channel_format(user.uid, user.email)
        end

        def private_channel_from_user_id(user_id)
            uid, email = User.where(id: user_id).pluck(:uid, :email).flatten
            return nil if uid.nil? || email.nil?

            private_channel_format(uid, email)
        end

        def send_private_message(to_user_id:, partial:, locals:)
            toChannels = [private_channel(@user), private_channel_from_user_id(to_user_id)]
            toChannels.each do |toChannel|
                Turbo::StreamsChannel.broadcast_replace_to(
                    toChannel,
                    target: "tag_private", 
                    partial: "messages/tag",
                    locals: {tag: "#private", count: ""}
                )

                Turbo::StreamsChannel.broadcast_prepend_to(
                    toChannel,
                    target: "messages_private", 
                    partial: partial,
                    locals: locals
                )
            end
        end

        def send_private_reply(applying, reply, partial = "replies/reply", locals = nil)
            [private_channel(applying.candidate), private_channel(applying.interviewer)].each do |toChannel|
                Turbo::StreamsChannel.broadcast_append_to(
                    toChannel,
                    target: "replies-#{applying.id}", 
                    partial: partial,
                    locals: locals || {reply: reply}
                )
            end
        end

        def create_and_send_private_reply(sender_id:, applying:, partial:, locals:)
            return if sender_id.nil? or applying.nil?
            
            content = ApplicationController.render(formats: [ :html ], partial: partial, locals: locals)
            reply = Reply.new(applying_id: applying.id, user_id: sender_id, content: content)
            if reply.save
                send_private_reply(applying, reply)
            end
        end

        private def private_channel_format(uid, email) # TODO: encrypt ???
            "%s-%s" % [uid, email]
        end
    end
end
