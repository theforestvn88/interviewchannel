# frozen_string_literal: true

class MessageRepo
    class << self
        def query(by_time:, by_tag: nil, by_user: nil)
            q = Message.by_updated_time(by_time)
            q = q.by_tag(by_tag) if by_tag
            q = q.by_owner(by_user.id) if by_user
            q
        end

        def count(by_time:, by_tag: nil, by_user: nil)
        end
    end
end
