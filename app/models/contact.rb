class Contact < ApplicationRecord
  belongs_to :user
  belongs_to :friend, class_name: "User", foreign_key: "friend_id"

  scope :recently, ->() {
    order(updated_at: :desc)
  }
end