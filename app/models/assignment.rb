# frozen_string_literal: true

class Assignment < ApplicationRecord
    belongs_to  :interview
    belongs_to  :interviewer, class_name: "User", foreign_key: "user_id"

    after_create  :create_engaging

    def create_engaging
      unless self.interview.applying_id.nil?
        Engaging.find_or_create_by(applying_id: self.interview.applying_id, user_id: self.user_id)
      end
    end
end
