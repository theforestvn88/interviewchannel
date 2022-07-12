class Applying < ApplicationRecord
  belongs_to :message, counter_cache: true
  belongs_to :candidate, :class_name => "User", :foreign_key => "candidate_id"
  belongs_to :interviewer, :class_name => "User", :foreign_key => "interviewer_id"
  has_many  :interviews, :dependent => :nullify # keep interviews even applying be destroyed
  has_many :replies, :dependent => :destroy
  has_many :engagings, :dependent => :destroy

  validates :candidate, uniqueness: { scope: :message }

  scope :by_created_time, ->(time_range) {
    where(created_at: time_range).order("applyings.created_at DESC")
  }

  scope :by_updated_time, ->(time_range) {
    where(updated_at: time_range).order("applyings.updated_at DESC")
  }

  scope :by_user_id, ->(user_id) {
    where(interviewer_id: user_id).or(where(candidate_id: user_id))
  }

  scope :by_job, ->(job_id) {
    where(message_id: job_id)
  }

  scope :engaged, ->(user_id) {
    joins(:engagings).where(engagings: {user_id: user_id})
  }

  after_create :create_engaging

  def control_by?(user)
    self.interviewer_id == user.id
  end

  def last_replies(to_user:)
    if [candidate_id, interviewer_id].include?(to_user.id)
      replies.last
    else
      replies.cc(to_user).last
    end
  end

  private def create_engaging
    Engaging.find_or_create_by(applying_id: self.id, user_id: self.candidate_id)
    Engaging.find_or_create_by(applying_id: self.id, user_id: self.interviewer_id)
  end
end
