# frozen_string_literal: true

class Messager
    module PrivateChannel
        def private_channel(user = @user)
            return nil if user.nil?

            private_channel_format(user.uid, user.email)
        end

        def private_channel_from_user_id(user_id)
            uid, email = User.where(id: user_id).pluck(:uid, :email).flatten
            return nil if uid.nil? || email.nil?

            private_channel_format(uid, email)
        end

        def send_private_message(to_user_id:, partial:, locals:, flash: nil)
            toChannels = [private_channel, private_channel_from_user_id(to_user_id)].uniq
            toChannels.each do |toChannel|
                Turbo::StreamsChannel.broadcast_replace_to(
                    toChannel,
                    target: "tag_inbox_content", 
                    partial: "messages/tag",
                    locals: {tag: "#inbox", count: 1, unread: true}
                )

                Turbo::StreamsChannel.broadcast_prepend_to(
                    toChannel,
                    target: "messages_inbox", 
                    partial: partial,
                    locals: locals
                )
            end

            send_private_flash(channel: toChannels.last, content: flash) if flash

            self
        end

        def send_private_reply(applying, reply, cc = [], partial: "replies/reply", locals: {}, flash: nil, **options)
            owner_channel = private_channel_from_user_id(reply.user_id)
            cc.map { |user_id| 
              private_channel_from_user_id(user_id) 
            }
            .concat([private_channel(applying.candidate), private_channel(applying.interviewer)])
            .uniq.each do |toChannel|
                Turbo::StreamsChannel.broadcast_append_to(
                    toChannel,
                    target: "replies-#{applying.id}", 
                    partial: partial,
                    locals: {reply: reply}.merge(locals)
                )

                Turbo::StreamsChannel.broadcast_replace_to(
                  toChannel,
                  target: "tag_inbox_content", 
                  partial: "messages/tag",
                  locals: {tag: "#inbox", count: 1, unread: true}
                )
                
                if toChannel != owner_channel
                  send_private_flash(channel: toChannel, content: (flash || reply.content[0..50] + "..."), **options)
                end
            end

            self
        end

        def create_and_send_private_reply(sender_id:, applying:, type:, cc: [], partial:, locals:, flash: nil, **options)
            return if sender_id.nil? or applying.nil?
            
            content = ApplicationController.render(formats: [ :html ], partial: partial, locals: locals)
            reply = Reply.new(applying_id: applying.id, user_id: sender_id, content: content, milestone: type)
            if reply.save
                send_private_reply(applying, reply, cc, locals: locals, flash: flash, **options)
            end

            self
        end

        def send_private_interview(interview, user, action:, target:, partial: "", locals: {})
            to_channel = private_channel(user)
            if action == :remove
                Turbo::StreamsChannel.broadcast_remove_to(to_channel, target: target)
            else
                Turbo::StreamsChannel.broadcast_action_later_to(
                    to_channel,
                    action: action,
                    target: target, 
                    partial: partial,
                    locals: locals
                )
            end

            self
        end

        def establish_private_chat_form(to_user_id:)
          Turbo::StreamsChannel.broadcast_append_to(
            private_channel,
            target: "chat-rooms", 
            partial: "users/private_chat_form",
            locals: {
              sender_id: @user.id, 
              receiver_id: to_user_id,
              private_chat_channel: private_chat_room_id(@user.id, to_user_id),
              private_chat_room_name: @user.name,
              show: true
            }
          )

          Turbo::StreamsChannel.broadcast_append_to(
            private_channel_from_user_id(to_user_id),
            target: "chat-rooms", 
            partial: "users/private_chat_form",
            locals: {
              sender_id: to_user_id, 
              receiver_id: @user.id,
              private_chat_channel: private_chat_room_id(@user.id, to_user_id),
              private_chat_room_name: @user.name,
              show: false
            }
          )

          self
        end

        def send_private_chat_message(message, to_user_id:)
          toChannels = [private_channel, private_channel_from_user_id(to_user_id)].uniq
          toChannels.each do |toChannel|
            Turbo::StreamsChannel.broadcast_append_to(
                toChannel,
                target: "chat-rooms", 
                partial: "users/private_chat_message",
                locals: {
                  message: message,
                  sender: @user,
                  private_chat_channel: private_chat_room_id(@user.id, to_user_id)
                }
            )
          end

          self
        end

        private def private_channel_format(uid, email) # TODO: encrypt ???
            "%s-%s" % [uid, email]
        end

        private def private_chat_room_id(sender_id, receiver_id)
          x, y = [sender_id, receiver_id].sort
          "private_chat_#{x}_#{y}"
        end
    end
end
