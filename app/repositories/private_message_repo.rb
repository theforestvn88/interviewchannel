# frozen_string_literal: true

class PrivateMessageRepo
    class << self
        def query(by_user:, by_time:)
            Applying.by_created_time(by_time).by_user_id(by_user.id)
        end
    end
end
