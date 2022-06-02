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

        def send_error_flash(channel:, content:)
            send_flash(channel: channel, content: content, css: "w-full absolute top-20 inset-x-0 z-100 pl-5 pr-10 py-2 shadow-xl drop-shadow-2xl border-y-2 border-l-2 border-red-900 bg-red-400 text-white")
        end

        def send_private_flash(channel:, content:)
            send_flash(channel: channel, content: content, tag: "#private")
        end
    end
end
