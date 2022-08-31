class Setting < ApplicationRecord
    def self.[](key)
        Setting.find_by(key: key)&.value
    end
end
