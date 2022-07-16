# frozen_string_literal: true

class RateLimiter
  attr_reader :user, :action, :max, :secs
  
  def initialize(user, action, max, secs, error_code = nil)
    @user = user
    @action = action
    @max = max
    @secs = secs
    @error_code = error_code

    @key = build_key
  end

  def check!
    return true if @user.admin?

    unless (count = Rails.cache.read(@key)) > 0
      Rails.cache.write(@key, 0, expires_in: @secs)
    end
    raise RateLimiter::LimitExceeded.new(@error_code) if count.to_i > @max

    Rails.cache.write(@key, count + 1)
  end

  def reset
  end

  private def build_key
    "limit-#{@user.id}-#{@action}"
  end

  class LimitExceeded < StandardError
    attr_reader :error_code

    def initialize(error_code)
      @error_code = error_code
    end

    def error_message; end
  end
end
