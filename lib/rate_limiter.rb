# frozen_string_literal: true

class RateLimiter
  attr_reader :user, :action, :max, :secs
  
  def initialize(user, action, max, error_code = nil, **options_cache)
    @user = user
    @action = action
    @max = max
    @error_code = error_code
    @options_cache = options_cache

    @key = build_key
  end

  def check!
    return true if @user&.admin?
    
    unless (count = Rails.cache.read(@key).to_i) > 0
      Rails.cache.write(@key, 0, **@options_cache)
    end
    raise RateLimiter::LimitExceeded.new(@action, @max, @error_code) if count >= @max

    Rails.cache.write(@key, count + 1, **@options_cache)
  end

  def reset
    Rails.cache.delete(@key)
  end

  private def build_key
    "limit-#{@user&.id || 0}-#{@action}"
  end

  class LimitExceeded < StandardError
    attr_reader :action, :limit, :error_code

    def initialize(action, limit, error_code)
      @action = action
      @limit = limit
      @error_code = error_code
    end

    def error_message
      return nil if error_code.nil?
      
      actions = action.to_s.split('_')
      time = error_code.to_s.split('_').first
      "You #{actions.first} too many #{actions.last} (#{limit} #{actions.last} / #{time})"
    end
  end
end
