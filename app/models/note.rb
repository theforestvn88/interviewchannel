# frozen_string_literal: true

class Note < ApplicationRecord
  belongs_to :user
  belongs_to :interview

  scope :forward_to, ->(user) {
    where("cc LIKE ?", "%#{user.name}%")
  }
end
