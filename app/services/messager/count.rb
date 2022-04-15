# frozen_string_literal: true

class Messager
    module Count
        def count_by_tag(tag)
            MessageRepo.count(by_tag: tag, by_time: @one_month_ago_utc...)
        end

        def count_by_user(user)
            MessageRepo.count(by_user: user, by_time: @one_month_ago_utc...)
        end

        def count_all
            count_by_tag nil
        end
    end
end
