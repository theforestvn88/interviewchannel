# frozen_string_literal: true

class CodeRepo
    class << self
        def save_code(interview_id:, path:, code:, expires_at:)
            Rails.cache.write(cached_code_key(interview_id, path), code, expires_at: expires_at)
        end

        def get_code(interview_id, path)
            Rails.cache.read(cached_code_key(interview_id, path))
        end

        private def cached_code_key(interview_id, file_path)
            "icode-#{interview_id}-#{file_path}"
        end
    end
end
