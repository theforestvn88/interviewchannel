# frozen_string_literal: true 

class Interview < ApplicationRecord
    belongs_to  :owner, class_name: "User" # required, the owner could be HR or the interviewer himself
    belongs_to  :interviewer, class_name: "User" # required
    belongs_to  :candidate, class_name: "User" # required
    belongs_to  :applying, optional: true

    validates :title, presence: true
    validate  :could_not_change_if_finnished, on: :update  
    validate  :could_not_change_candidate, on: :update
    validate  :timespan_ok?

    scope :as_owner, ->(owner) {
        where(owner_id: owner.id)
    }

    scope :as_interviewer, ->(interviewer) {
        where(interviewer_id: interviewer.id)
    }

    scope :as_candidate, ->(candidate) {
        where(candidate_id: candidate.id)
    }

    scope :by_time, ->(from_utc, to_utc) {
        range = from_utc..to_utc
        where(start_time: range).or(where(end_time: range))   
    }

    scope :by_keyword, ->(keyword) {
        return self if keyword.nil?

        keywords = ["%#{keyword}%"] * 2
        joins("INNER JOIN users ON interviews.interviewer_id = users.id OR interviews.candidate_id = users.id")
            .where("users.name ILIKE ? OR interviews.note ILIKE ?", *keywords)
            .distinct
    }

    def owner?(user)
        return self.owner_id == user.id
    end

    def involve?(user)
        self.interviewer_id == user.id || self.candidate_id == user.id
    end

    class ModifyingPolicy < RuntimeError; end

    def start_time_minutes(timezone = "UTC")
        (self.start_time.in_time_zone(timezone).seconds_since_midnight/60).floor
    end

    def end_time_minutes(timezone = "UTC")
        (self.end_time.in_time_zone(timezone).seconds_since_midnight/60).floor
    end

    def finished?
        self.end_time <= Time.now.utc
    end

    def timespan_ok?
        unless self.end_time > self.start_time && self.start_time > Time.now.utc
            self.errors.add(:time, "is not appropriate!")
        end
    end

    def could_not_change_candidate
        if candidate_id_changed? && self.persisted?
            self.errors.add(:candidate, "is not allowed to change!")
        end
    end

    def could_not_change_if_finnished
        if self.persisted? && self.finished?
            self.errors.add(:interview, "is finished!")
        end
    end
end
