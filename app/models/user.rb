# frozen_string_literal: true

# Proposal:
#   + user profiles
#   + tags
#   + channels  users/tags
#   + subscriptions: user subscribe/unsubscribe channels 
#   + interviewers post jobs on his channel (expire 1 month, rate limit 30 posts/month, could be reported)
#   + candidate receive messages (expire 1 month) + email?
#   + candidate apply -> send message to interviewer (expire 1 month) + email to interviewer?
#   + interviewers notice then process  + email to candidate?
#   + candidate post `wanted` on his channel with tag e.g `Ruby` (expire 1 month, rate limit 30 posts/month, could be reported)
#   + interviewer notice if he subscribe the `Ruby` channel
#   + interviewer reply (expire 1 month, rate limit 100 reply/month, could be reported)
#
# Solution:
#     + subscriptions: channels are `user uid` or tags -> user has_many followers(users), 
#     + user has tags combine string `#Ruby#Rails`
#     + messages table: <id, owner_id, channel, content_text_no_attachments, expired_at>
#         . index updated_at (or expired_at) ?
#         . channel are tag names 
#         . a schedule job to delete expired messages
#     + interviewer post job message on tags-channel
#     + user receive message (real time): turbo-stream on user's tags
#     + query messages: 
#         . (full text) search tag names + user names(in last 30 days or expired_at 30.days.from_now) ???
#         . a cache counting messages per channel (expire 1 month) ???
#         . list messages: lobster style
#             . edit|user-avatar| #first_tag first-line-of-content #3-next-tags [...] <- click here will load full content
#             . dele|user-avatar| posted by 5 minutes ago | 100 views | 1 apply  <Apply Now> <- click here to show popup applying
#             .       ^ hover user-avatar will load/show user brief-profile
#             
#     + applying table: <id, message_id, owner_id, candidate_id, status_enum, expired_at>
#         . a schedule job to delete expired apply
#     + process apply -> create interview, delete apply, notify to user
# 

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

  scope :suggest, ->(keyword) {
    keywords = ["%#{keyword}%"] * 2
    where("name ILIKE ? OR email ILIKE ?", *keywords)
  }
end

