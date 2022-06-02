# frozen_string_literal: true

class Message < ApplicationRecord
  belongs_to :owner,
             :class_name => "User",
             :foreign_key => "user_id",
             :inverse_of => :sent_messages

  has_many :applyings, :dependent => :destroy

  scope :by_updated_time, ->(time_range) {
    where(updated_at: time_range)
  }

  scope :by_tags, ->(tags) {
    where(
      (["channel ILIKE ?"] * tags.size).join(" OR "), 
      *tags.map { |t| "%#{t}%" }
    )
  }

  scope :by_owner, ->(owner_id) {
    where(user_id: owner_id)
  }

  def tags
    (channel || "").split(" ").push("#all").map(&:downcase)
  end

  def tags=(_tags)
    self.channel = _tags.map {|t| "##{t}"}.uniq.join(" ")
  end

  def expired?
    self.expired_at <= Time.now.utc
  end

  # turbo stream
  def targets
    tags.map {|t| "#messages_#{t.gsub('#','')}"}.join(", ")
  end

  after_create_commit  -> { broadcast_prepend_later_to :messages, target: nil, targets: targets }
  after_update_commit  -> { broadcast_replace_later_to self }
  after_destroy_commit -> { broadcast_remove_to self }
end
