# frozen_string_literal: true

class Assignment < ApplicationRecord
    belongs_to  :interview
    belongs_to  :user
end
