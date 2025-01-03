class Reply < ApplicationRecord
  belongs_to :applying, touch: true
  belongs_to :user

  TYPES = [
    COMMENT_TYPE = "comment",
    INTERVIEW_TYPE = "interview",
    ASSIGNMENT_TYPE = "assignment",
    APPLY_TYPE = "apply"
  ].freeze

  enum milestone: {
    comment: COMMENT_TYPE,
    interview: INTERVIEW_TYPE,
    assignment: ASSIGNMENT_TYPE,
    apply: APPLY_TYPE
  }, _suffix: true

  scope :cc, ->(user) {
    where("content LIKE ?", "%#{user.name}%")
  }

  def time_milestone?
    !comment_milestone?
  end

  # LIMIT_PER_DAY = 1000
end
