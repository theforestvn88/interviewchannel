# frozen_string_literal: true

class User < ApplicationRecord
  def self.find_or_create_from_omniauth(auth)
    user = find_by(uid: auth['uid'])
    return user if user.present?

    create! do |user|
      user.uid = auth['uid']
      user.name = auth.info['nickname']
      user.email = auth.info['email']
    end
  end
end

