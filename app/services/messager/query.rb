# frozen_string_literal: true

class Messager
    module Query
        def recently(*tags)
            _tags = tags.filter {|t| t.to_s != "#all"}
            MessageRepo.query(by_tags: _tags, by_time: @one_month_ago_utc...)
        end

        def own_by_me
            MessageRepo.query(by_user: @user, by_time: @one_month_ago_utc...)
        end

        def private_messages(user)
            PrivateMessageRepo.query(by_user: user, by_time: @one_month_ago_utc...)
        end
    end
end
