# frozen_string_literal: true

class User < ApplicationRecord
  has_many :sent_messages,
           :class_name => "Message",
           :foreign_key => "user_id",
           :inverse_of => :owner,
           :dependent => :destroy

  def self.find_or_create_from_omniauth(auth)
    user = find_by(uid: auth['uid'])
    return user if user.present?

    create! do |user|
      user.uid = auth['uid']
      user.name = auth.info['nickname']
      user.email = auth.info['email']
      user.image = auth.info['image']
      user.github = auth.info["urls"]['GitHub']
    end
  end

  def set_session_timezone(ss_timezone)
    Rails.cache.write("ss_timezone_#{self.id}", ss_timezone, expires_in: 12.hours)
  end
  
  def curr_timezone
    Rails.cache.fetch("ss_timezone_#{self.id}", expires_in: 12.hours) { "UTC" }
  end

  def tags=(tags_input)
    self.watch_tags = tags_input.map {|t| "##{t}"}.join(" ")
  end

  scope :suggest, ->(keyword) {
    keywords = ["%#{keyword}%"] * 2
    where("name ILIKE ? OR email ILIKE ?", *keywords)
  }
end

