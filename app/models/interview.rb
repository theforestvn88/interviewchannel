# frozen_string_literal: true

class Interview < ApplicationRecord
    belongs_to  :interviewer, class_name: "User" # required
    belongs_to  :candidate, class_name: "User" # allow unregister users, interviewer could use `note` to note candidate info.
end
