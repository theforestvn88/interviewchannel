class Applying < ApplicationRecord
  belongs_to :message
  belongs_to :candidate, :class_name => "User", :foreign_key => "candidate_id"

  validates :candidate, uniqueness: { scope: :message }
end
