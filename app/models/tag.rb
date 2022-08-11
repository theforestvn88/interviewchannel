class Tag < ApplicationRecord
    scope :by_group, ->(_group) {
        Tag.where(category: _group).order(pos: :asc)
    }
    
    def jobs_count
        MessageRepo.count(by_tag: self.name, by_time: 1.month.ago.utc..., expires_in: 1.day)
    end
end
