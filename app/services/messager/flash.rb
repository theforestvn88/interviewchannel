# frozen_string_literal: true

class Messager
    module Flash
        def send_flash(channel:, content:, **options)
            Turbo::StreamsChannel.broadcast_replace_to(
                channel,
                target: "flash", 
                partial: "shared/flash",
                locals: {content: content, **options}
            )

            self
        end

        def send_flash_to_user(user, content:, **options)
          send_flash(channel: private_channel_from_user_id(user.id), content: content, **options)
        end

        def send_error_flash(channel: nil, error:)
            send_flash(channel: channel || private_channel_from_user_id(@user.id), content: error, css: "w-full fixed top-0 inset-x-0 z-50 pl-5 pr-10 py-2 shadow-xl drop-shadow-2xl border-y-2 border-l-2 border-red-900 bg-red-400 text-white")
        end

        def send_model_error_flash(model)
            send_error_flash(error: model.errors.first.full_message)
        end

        def send_private_flash(channel:, content:, **options)
            send_flash(channel: channel, content: content, **options)
        end
    end
end
