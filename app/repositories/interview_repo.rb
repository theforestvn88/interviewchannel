# frozen_string_literal: true

class InterviewRepo
    class << self
        def set_broadcast_lock(interview_id, user_id, expires_at:)
            Rails.cache.write(broadcast_lock_key(interview_id), user_id, expires_at: expires_at)
        end
        
        def get_broadcast_lock(interview_id)
            Rails.cache.read(broadcast_lock_key(interview_id))
        end

        def delete_broadcast_lock(interview_id)
            Rails.cache.delete(broadcast_lock_key(interview_id))
        end

        private def broadcast_lock_key(interview_id)
            "ilock-#{interview_id}"
        end

        def get_coderun_lock(interview_id)
            Rails.cache.read(coderun_lock_key(interview_id))
        end

        def set_coderun_lock(interview_id, user_id, expires_at:)
            Rails.cache.write(coderun_lock_key(interview_id), user_id, expires_at: expires_at)
        end

        def delete_coderun_lock(interview_id)
            Rails.cache.delete(coderun_lock_key(interview_id))
        end

        private def coderun_lock_key(interview_id)
            "crlock-#{interview_id}"
        end
    end
end
