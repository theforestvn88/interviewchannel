class SessionTimezone
    def initialize app, *args, &block
        @app = app
    end

    def call env
        request = ActionDispatch::Request.new(env)
        if session_timezone = request.params["timezone"]
            request.session["timezone"] = session_timezone
        end
        @app.call(env)
    end
end
