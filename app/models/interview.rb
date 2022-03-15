# frozen_string_literal: true

class Interview < ApplicationRecord
    belongs_to  :interviewer, class_name: "User" # required
    belongs_to  :candidate, class_name: "User", optional: true # allow unregister users, interviewer could use `note` to note candidate info.

    scope :as_interviewer, ->(interviewer) {
        where(interviewer_id: interviewer.id)
    }

    scope :as_candidate, ->(candidate) {
        where(candidate_id: candidate.id)
    }

    scope :by_time, ->(from, to) {
        range = from..to
        where(start_time: range).or(where(end_time: range))   
    }
end
