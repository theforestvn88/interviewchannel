class ClearMessagesJob < ApplicationJob
    queue_as :low

    def perform
        now = Time.now.utc
        
        # destroy all expired messages
        Message.where(expired_at: ..now).destroy_all

        # destroy all non-applied 1/2 month from now
        # if there're so much messages
        # two_weeks_ago = now - 2.weeks
        # Message.where(created_at: ..two_weeks_ago)
        #     .where.missing(:applyings)
        #     .destroy_all
    end
end
