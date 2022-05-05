# frozen_string_literal: true

class Messager
    module Query

        PAGE = 20

        def recently(*tags, offset_time: Time.now.utc, limit: PAGE)
            _tags = tags.filter {|t| t.to_s != "#all"}
            MessageRepo.query(by_tags: _tags, by_time: @one_month_ago_utc..offset_time, limit: limit)
        end

        def own_by_me(offset_time: Time.now.utc, limit: PAGE)
            MessageRepo.query(by_user: @user, by_time: @one_month_ago_utc..offset_time, limit: limit)
        end

        def private_messages(user, offset_time: Time.now.utc, limit: PAGE)
            PrivateMessageRepo.query(by_user: user, by_time: @one_month_ago_utc..offset_time, limit: limit)
        end
    end
end
