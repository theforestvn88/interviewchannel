# frozen_string_literal: true

class Messager
    module Query

        PAGE = 20

        def recently(*tags, offset: 0, limit: PAGE)
            _tags = tags.filter {|t| t.to_s != "#all"}
            MessageRepo.query(by_tags: _tags, by_time: @one_month_ago_utc..., offset: offset, limit: limit)
        end

        def own_by_me(offset: 0, limit: PAGE)
            MessageRepo.query(by_user: @user, by_time: @one_month_ago_utc..., offset: offset, limit: limit)
        end

        def private_messages(user, offset: 0, limit: PAGE)
            PrivateMessageRepo.query(by_user: user, by_time: @one_month_ago_utc..., offset: offset, limit: limit)
        end
    end
end
