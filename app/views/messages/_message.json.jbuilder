json.extract! message, :id, :channel, :content, :expired_at, :user_id, :created_at, :updated_at
json.url message_url(message, format: :json)
