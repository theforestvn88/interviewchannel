class Applying < ApplicationRecord
  belongs_to :message, counter_cache: true
  belongs_to :candidate, :class_name => "User", :foreign_key => "candidate_id"
  belongs_to :interviewer, :class_name => "User", :foreign_key => "interviewer_id"
  has_many  :interviews, :dependent => :nullify # keep interviews even applying be destroyed
  has_many :replies, :dependent => :destroy

  validates :candidate, uniqueness: { scope: :message }

  scope :by_created_time, ->(time_range) {
    where(created_at: time_range).order("created_at DESC")
  }

  scope :by_updated_time, ->(time_range) {
    where(updated_at: time_range).order("updated_at DESC")
  }

  scope :by_user_id, ->(user_id) {
    where(interviewer_id: user_id).or(where(candidate_id: user_id))
  }

  scope :by_job, ->(job_id) {
    where(message_id: job_id)
  }

  def control_by?(user)
    self.interviewer_id == user.id
  end
end
