# frozen_string_literal: true

class Message < ApplicationRecord
  belongs_to :owner,
             :class_name => "User",
             :foreign_key => "user_id",
             :inverse_of => :sent_messages

  has_many :applyings, :dependent => :destroy

  validates_presence_of :channel

  after_create_commit  -> { broadcast_prepend_later_to :messages, target: nil, targets: targets }
  after_update_commit  -> { broadcast_replace_later_to self }
  after_destroy_commit -> { broadcast_remove_to self }

  after_save -> { owner.increment!(:messages_count) }

  # LIMIT_PER_DAY = 10

  scope :by_updated_time, ->(time_range) {
    where(updated_at: time_range)
  }

  scope :by_tags, ->(tags) {
    _tags = tags.map { |t| "'%#{t}%'" }.join(',')
    where("channel ILIKE ANY (array[#{_tags}])")
  }

  scope :similarity_tags, ->(tags) {
    by_tags(tags)
      .order(Arel.sql("similarity(channel, '#{ActiveRecord::Base.connection.quote_string(tags.join(' '))}') DESC"))
  }

  scope :by_owner, ->(owner_id) {
    where(user_id: owner_id)
  }

  def tags
    (channel || "").split(" ").push("#all").map(&:downcase)
  end

  def tags=(_tags)
    self.channel = _tags.map {|t| t.strip.gsub("#", "").downcase}.map {|t| "##{t}"}.uniq.join(" ")
  end

  def split_tags
    self.channel.blank? ? [] : self.channel.split("#").map(&:strip).reject(&:blank?)
  end

  def own_by?(user)
    self.user_id == user&.id
  end

  def expired?
    self.expired_at <= Time.now.utc
  end

  def close!
    self.update!(expired_at: Time.now.utc)
  end

  def applied_by?(user)
    return false if user.nil?
    
    Applying.where(message_id: self.id, candidate_id: user.id).first.present?
  end

  # turbo stream
  def targets
    tags.map {|t| "#messages_#{t.gsub('#','')}"}.join(", ")
  end
end
