module MessagesHelper

  def job_link_tag(message_id, **options)
    link_to "Job##{message_id}", message_path(message_id), data: {turbo_frame: "home-content"}, **options
  end

  def message_list_id(tags)
    "messages_#{ tags&.gsub(/[\#\&]/,'')&.downcase || 'all' }"
  end

  def messages_by_me_id(user)
    "messages_u#{user.id}"
  end
end
