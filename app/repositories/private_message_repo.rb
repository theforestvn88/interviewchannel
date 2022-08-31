# frozen_string_literal: true

class PrivateMessageRepo
    class << self
        def query(by_user:, by_time:, limit:, by_user_id: nil, by_job: nil)
          query_applyings = Applying
                              .by_updated_time(by_time)
                              .engaged(by_user_id > 0 ? by_user_id : by_user.id)
          query_applyings = query_applyings.by_job(by_job) if by_job > 0
          query_applyings.limit(limit)
        end

        def inbox_filter(by_user:)
          Rails.cache.fetch("inbox-filter-#{by_user.id}", expires_in: 1.minute) {
            applying_ids = Applying.joins(:engagings).where(engagings: {user_id: by_user.id}).pluck(:applying_id)
            filterings = Applying.joins(:engagings).where(applyings: {id: applying_ids}).pluck(:message_id, :user_id)
            job_ids = filterings.map(&:first).uniq
            user_ids = filterings.map(&:last).uniq
            users = User.where(id: user_ids).pluck(:id, :name, :email)
            
            [ job_ids, users ]
          }
        end
    end
end
