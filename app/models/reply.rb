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

  def time_milestone?
    !comment_milestone?
  end
end
