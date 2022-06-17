# frozen_string_literal: true

class User < ApplicationRecord
  include OmniAuthParser

  has_many :sent_messages,
           :class_name => "Message",
           :foreign_key => "user_id",
           :inverse_of => :owner,
           :dependent => :destroy

  def self.find_or_create_by_omniauth(auth)
    # exist user ?
    user = where(email: parse_user_emails(auth)).first
    if user.present?
      # update merge infomation
      if user.github.nil? && (gihub = parse_github(auth)).present?
        user.github = gihub
        user.save
      end
      return user
    end

    # create new user !
    create! do |user|
      user.uid = parse_user_uid(auth)
      user.name = parse_user_name(auth)
      user.email = parse_user_primary_email(auth)
      user.image = parse_user_image(auth)
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
    self.watch_tags = tags_input.map {|t| t.present? ? "##{t.strip}" : ""}.join(" ").strip
  end

  def afk?
    self.watch_tags.blank?
  end

  scope :suggest, ->(keyword) {
    keywords = ["%#{keyword.strip}%"] * 2
    where("name ILIKE ? OR email ILIKE ?", *keywords)
  }
end

