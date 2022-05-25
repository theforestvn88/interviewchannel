# frozen_string_literal: true

class User < ApplicationRecord
  include OmniAuthParser

  has_many :sent_messages,
           :class_name => "Message",
           :foreign_key => "user_id",
           :inverse_of => :owner,
           :dependent => :destroy

  def self.find_or_create_from_omniauth(auth)
    user_uid = parse_user_uid(auth)
    user = find_by(uid: user_uid)
    return user if user.present?

    create! do |user|
      user.uid = user_uid
      user.name, user.email, user.image = parse_user_info(auth)
      user.github = parse_github(auth)
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

