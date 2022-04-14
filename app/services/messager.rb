# frozen_string_literal: true

class Messager
    include Query
    include Count

    def initialize(user = nil, timezone = nil)
        @user = user
        @timezone = timezone || "UTC"
        @one_month_ago_utc = 1.month.ago.in_time_zone(@timezone).utc
    end
end
