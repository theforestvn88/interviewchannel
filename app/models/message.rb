class Message < ApplicationRecord
  belongs_to :owner,
             :class_name => "User",
             :foreign_key => "user_id",
             :inverse_of => :sent_messages

  scope :by_updated_time, ->(from_time) {
    where(updated_at: from_time...).order("updated_at DESC")
  }

  scope :by_tag, ->(tags) {
    where(
      (["channel ILIKE ?"] * tags.size).join(" OR "), 
      *tags.map { |t| "%#{t}%" }
    )
  }

  scope :by_owner, ->(owner_id) {
    where(user_id: owner_id)
  }
end
