# frozen_string_literal: true

class Interview < ApplicationRecord
    belongs_to  :interviewer, class_name: "User" # required
    belongs_to  :candidate, class_name: "User", optional: true # allow unregister users, interviewer could use `note` to note candidate info.

    validates :note, presence: true
    
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
        return interviewer.id == user.id
    end

    class ModifyingPolicy < RuntimeError; end

    def start_time_minutes(timezone = "UTC")
        (self.start_time.in_time_zone(timezone).seconds_since_midnight/60).floor
    end

    def end_time_minutes(timezone = "UTC")
        (self.end_time.in_time_zone(timezone).seconds_since_midnight/60).floor
    end
end
