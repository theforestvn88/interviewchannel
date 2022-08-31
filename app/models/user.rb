# frozen_string_literal: true

class User < ApplicationRecord
  include OmniAuthParser
  include SocialLinks

  has_many :sent_messages,
           :class_name => "Message",
           :foreign_key => "user_id",
           :inverse_of => :owner,
           :dependent => :destroy

  has_many :contacts
  has_many :friends, through: :contacts, source: :friend

  validate :validate_social_links

  before_save :upd_suggest_trgm

  attr_accessor :custom_name

  scope :suggest, ->(keyword) {
    where("suggest_trgm ILIKE ?", "%#{keyword.strip}%")
  }

  def self.find_or_create_by_omniauth(auth)
    # exist user ?
    _provider = parse_provider(auth)
    _social_link = parse_social_link(auth)
    _image = parse_user_image(auth) || ""
    _email = parse_user_emails(auth)

    user = where(email: _email).first
    if user.present?
      # update merge infomation
      if user.image.blank?
        user.image = _image
      end

      user.social ||= {}
      user.social[_provider] = _social_link unless _social_link.nil?

      user.save if user.changed?
      return user
    end

    # create new user !
    create! do |user|
      user.uid = parse_user_uid(auth)
      user.name = parse_user_name(auth)
      user.email = parse_user_primary_email(auth)
      user.image = _image
      user.social = {}.tap {|s| s[_provider] = _social_link}
    end
  end

  def tags=(tags_input)
    self.watch_tags = tags_input.map {|t| t.present? ? "##{t.strip.downcase}" : ""}.join(" ").strip
  end

  def split_tags
    self.watch_tags.blank? ? [] : self.watch_tags.split("#").map(&:strip).reject(&:blank?)
  end

  def afk?
    self.watch_tags.blank?
  end

  def validate_social_links
    return if social.nil?

    social_support.each do |social_domain|
      if social.has_key?(social_domain)
        errors.add(:social, "Error: Invalid #{social_domain} link") unless social_link_valid?(social_domain, social[social_domain])
      end
    end
  end

  def social_links
    social || {}
  end

  def recently_contacts
    contacts.recently
  end

  def admin?
    self.uid == Rails.application.credentials.admin[:uid].to_s &&
      self.email == Rails.application.credentials.admin[:email].to_s
  end

  def banned?
    self.updated_at > Time.now.utc
  end

  def ban(time = 1.year.from_now)
    self.update(updated_at: time)
  end
  
  def unban
    self.update(updated_at: Time.now.utc)
  end

  def need_setup?
    self.afk? # or something ...
  end

  private def upd_suggest_trgm
    self.suggest_trgm = "#{self.name} #{self.email}"
  end
end

