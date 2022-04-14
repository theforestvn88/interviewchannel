# frozen_string_literal: true

class Messager
    module Query
        def recently(*tags)
            MessageRepo.query(by_tags: tags, by_time: @one_month_ago_utc...)
        end

        def own_by_me
            MessageRepo.query(by_user: @user, by_time: @one_month_ago_utc...)
        end
    end
end
