class Message < ApplicationRecord
  belongs_to :owner,
             :class_name => "User",
             :foreign_key => "user_id",
             :inverse_of => :sent_messages

  has_many :applyings, :dependent => :destroy

  scope :by_updated_time, ->(time_range) {
    where(updated_at: time_range).order("updated_at DESC")
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

  # turbo stream
  def targets
    tags.map {|t| "#messages_#{t.gsub('#','')}"}.join(", ")
  end

  after_create_commit  -> { broadcast_prepend_later_to :messages, target: nil, targets: targets }
  after_update_commit  -> { broadcast_replace_later_to self }
  after_destroy_commit -> { broadcast_remove_to self }

  def applying_count
    Rails.cache.fetch applying_count_cache_key, expires_in: 1.day do
      self.applyings.count
    end
  end

  def refresh_applying_count
    Rails.cache.delete(applying_count_cache_key)
    applying_count
  end

  private def applying_count_cache_key
    @applying_count_key ||= "ms_#{self.id}_ap_count"
  end
end
