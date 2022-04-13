# frozen_string_literal: true

class Messager
    module Query
        def recently(*tags)
            MessageRepo.query(by_tag: tags, by_time: 1.month.ago.utc...)
        end

        def own_by_me
            MessageRepo.query(by_user: @user, by_time: 1.month.ago.utc...)
        end
    end
end
