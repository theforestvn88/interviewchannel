# frozen_string_literal: true

class Messager
    module Model
        def create_message(message_params)
            message = Message.new(message_params.merge({user_id: @user.id, expired_at: 1.hour.from_now.in_time_zone(@timezone).utc}))
            if message.save
                increase_then_broadcast_counter(message)
            else
                send_error_flash(channel: private_channel_from_user_id(@user.id), content: message.errors.first.full_message)
            end

            message
        end

        def broadcast_replace(model)
            if model.respond_to?(:broadcast_replace_later_to)
                model.broadcast_replace_later_to model
            end

            self
        end
    end
end
