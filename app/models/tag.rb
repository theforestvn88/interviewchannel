class Tag < ApplicationRecord
    def jobs_count
        MessageRepo.count(by_tag: self.name, by_time: 1.month.ago.utc..., expires_in: 1.day)
    end
end
