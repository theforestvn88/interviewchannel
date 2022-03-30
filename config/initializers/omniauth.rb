Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, 
            Rails.application.credentials.github_omniauth[:client_id],
            Rails.application.credentials.github_omniauth[:client_secret],
            scope: "read:user"

  on_failure do
    # back to home
    Rack::Response.new(['302 Moved'], 302, 'Location' => "/").finish
  end
end

require_relative "../../lib/middleware/session_timezone"
Rails.application.config.middleware.insert_before OmniAuth::Builder, SessionTimezone