# frozen_string_literal: true 

class Interview < ApplicationRecord
    belongs_to  :owner, class_name: "User" # required, the owner could be HR or the interviewer himself
    belongs_to  :interviewer, class_name: "User" # required
    belongs_to  :candidate, class_name: "User" # required
    belongs_to  :applying, optional: true

    has_many    :assignments, dependent: :destroy
    has_many    :interviewers, through: :assignments, source: :user

    has_many    :rounds, class_name: "Interview", foreign_key: "head_id", inverse_of: :head, dependent: :nullify
    belongs_to  :head, class_name: "Interview", foreign_key: "head_id", inverse_of: :rounds, optional: true

    STATE_WAIT = 'wait'
    STATE_IN_PROCESS = 'in_process'
    STATE_FINISH = 'finish'
    STATE_CANCELED = 'canceled'
    enum state: { wait: STATE_WAIT, in_process: STATE_IN_PROCESS, finish: STATE_FINISH, canceled: STATE_CANCELED }

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
        joins("INNER JOIN users ON interviews.interviewer_id = users.id OR interviews.candidate_id = users.id OR interviews.owner_id = users.id")
            .where("users.name ILIKE ? OR interviews.title ILIKE ?", *keywords)
            .distinct
    }

    def owner?(user)
        return self.owner_id == user.id
    end

    def involve?(user)
        self.interviewer_id == user.id || self.candidate_id == user.id
    end

    def started?
        !self.canceled? && (self.finish? || (self.in_process? || try_start!))
    end

    def try_start!
        if rush_time?
            self.in_process!
            true
        else
            false
        end
    end

    def finished?
        !self.canceled? && (self.finish? || set_finish!)
    end

    def set_finish!
        if over_time?
            self.finish!
            true
        else
            false
        end
    end

    def over_time?
        self.end_time.utc < Time.now.utc
    end

    def rush_time?
        self.start_time.utc <= Time.now.utc
    end

    def countdown
        self.finished? ? 0 : (self.start_time - Time.now.utc).round
    end

    class ModifyingPolicy < RuntimeError; end

    def start_time_minutes(timezone = "UTC")
        (self.start_time.in_time_zone(timezone).seconds_since_midnight/60).floor
    end

    def end_time_minutes(timezone = "UTC")
        (self.end_time.in_time_zone(timezone).seconds_since_midnight/60).floor
    end

    def timespan_ok?
        unless self.end_time > self.start_time && 
            ((!self.persisted? && !rush_time?) || (self.persisted? && (!self.start_time_changed? || !rush_time?)))
            self.errors.add(:time, "is not appropriate!")
        end
    end

    def could_not_change_candidate
        if self.persisted? && candidate_id_changed?
            self.errors.add(:candidate, "is not allowed to change!")
        end
    end

    def could_not_change_if_finnished
        if self.persisted? && self.state_was == STATE_FINISH
            self.errors.add(:interview, "is finished!")
        end
    end

    def timeline
        [self] + self.rounds.sort_by(&:round)
    end
end
