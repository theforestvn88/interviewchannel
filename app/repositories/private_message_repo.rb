# frozen_string_literal: true

class PrivateMessageRepo
    class << self
        def query(by_user:, by_time:, limit:, by_user_id: nil, by_job: nil)
          query_applyings = Applying.by_updated_time(by_time).by_user_id(by_user_id > 0 ? by_user_id : by_user.id)
          query_applyings = query_applyings.by_job(by_job) if by_job > 0
          query_applyings.limit(limit)
        end

        def filter(by_user:)
          Rails.cache.fetch("filter-#{by_user.id}", expires_in: 1.minute) {
            applyings = Applying.by_user_id(by_user.id).pluck(:message_id, :interviewer_id, :candidate_id)
            job_ids = applyings.map {|a| a[0]}.uniq
            user_ids = applyings.map {|a| [a[1], a[2]]}.flatten.uniq
            users = User.where(id: user_ids).pluck(:id, :name, :email)
            
            [ job_ids, users ]
          }
        end
    end
end
