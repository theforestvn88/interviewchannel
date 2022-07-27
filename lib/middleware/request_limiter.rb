# frozen_string_literal: true

class RequestLimiter
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    ip = request.ip
    rate_limiter = RateLimiter.new(nil, "request-#{ip}", 200, nil, expires_in: 10.minutes)
    
    begin
      rate_limiter.check!
      @app.call(env)
    rescue RateLimiter::LimitExceeded => e
      [429, {}, [{message: "Too Many Requests !!!"}]]
    end
  end
end
