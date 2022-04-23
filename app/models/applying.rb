class Applying < ApplicationRecord
  belongs_to :message
  belongs_to :candidate, :class_name => "User", :foreign_key => "candidate_id"
  belongs_to :interviewer, :class_name => "User", :foreign_key => "interviewer_id"

  validates :candidate, uniqueness: { scope: :message }

  has_many :replies, :dependent => :destroy

  scope :by_created_time, ->(time_range) {
    where(created_at: time_range).order("created_at DESC")
  }

  scope :by_user_id, ->(user_id) {
    where(interviewer_id: user_id).or(where(candidate_id: user_id))
  }
end
