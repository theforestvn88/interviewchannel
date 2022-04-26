# frozen_string_literal: true

class PrivateMessageRepo
    class << self
        def query(by_user:, by_time:, offset:, limit:)
            Applying.by_created_time(by_time).by_user_id(by_user.id).offset(offset).limit(limit)
        end
    end
end
