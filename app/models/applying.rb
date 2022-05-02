class Applying < ApplicationRecord
  belongs_to :message, touch: true
  belongs_to :candidate, :class_name => "User", :foreign_key => "candidate_id"
  belongs_to :interviewer, :class_name => "User", :foreign_key => "interviewer_id"
  has_many  :interviews # keep interviews even applying be destroyed
  has_many :replies, :dependent => :destroy

  validates :candidate, uniqueness: { scope: :message }

  scope :by_created_time, ->(time_range) {
    where(created_at: time_range).order("created_at DESC")
  }

  scope :by_user_id, ->(user_id) {
    where(interviewer_id: user_id).or(where(candidate_id: user_id))
  }
end
