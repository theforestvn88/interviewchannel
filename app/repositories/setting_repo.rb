# frozen_string_literal: true

class SettingRepo
    class << self
        def fetch(keys, expires_in: 1.hour)
            Rails.cache.fetch(keys, expires_in: expires_in) do
                _keys = keys.split(".")
                key = _keys.shift
                value = JSON.parse(Setting[key].to_json)
                _keys.empty? ? value : value.dig(*_keys)
            end
        end
    end
end
