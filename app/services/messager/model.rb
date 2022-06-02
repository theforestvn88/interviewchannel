# frozen_string_literal: true

class Messager
    module Model
        def create_message(message_params)
            message = Message.new(message_params.merge({user_id: @user.id, expired_at: 1.month.from_now.in_time_zone(@timezone).utc}))
            if message.save
                increase_then_broadcast_counter(message)
            else
                send_model_error_flash(message)
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
