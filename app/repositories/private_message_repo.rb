# frozen_string_literal: true

class PrivateMessageRepo
    class << self
        def query(by_user:, by_time:, limit:)
            Applying.by_updated_time(by_time).by_user_id(by_user.id).limit(limit)
        end
    end
end
