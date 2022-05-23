class ClearMessagesJob < ApplicationJob
    queue_as :low

    def perform
        now = Time.now.utc
        
        # destroy all messages 1 month from now
        one_month_ago = now - 1.month
        Message.where(created_at: ..one_month_ago).destroy_all

        # destroy all non-applied 1/2 month from now
        two_weeks_ago = now - 2.weeks
        Message.where(created_at: ..two_weeks_ago)
            .where.missing(:applyings)
            .destroy_all
    end
end
