# frozen_string_literal: true

class InterviewRepo
    class << self
        def set_lock(interview_id, user_id, expires_at:)
            Rails.cache.write(lock_key(interview_id), user_id, expires_at: expires_at)
        end
        
        def get_lock(interview_id)
            Rails.cache.read(lock_key(interview_id))
        end

        private def lock_key(interview_id)
            "ilock-#{interview_id}"
        end
    end
end
