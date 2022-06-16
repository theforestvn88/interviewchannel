# frozen_string_literal: true

class Assignment < ApplicationRecord
    belongs_to  :interview
    belongs_to  :interviewer, class_name: "User", foreign_key: "user_id"
end
