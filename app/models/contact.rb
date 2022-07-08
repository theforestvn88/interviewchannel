class Contact < ApplicationRecord
  belongs_to :user
  belongs_to :friend, class_name: "User", foreign_key: "friend_id"

  scope :recently, ->() {
    order(updated_at: :desc)
  }

  scope :suggest, ->(key) {
    where("custom_name ILIKE ?", "%#{key.strip}%")
  }

  def self.hit(user_id, friend_id)
    Contact.find_by(user_id: user_id, friend_id: friend_id)&.touch
  end
end