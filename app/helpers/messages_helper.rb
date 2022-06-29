module MessagesHelper

  def job_link_tag(message_id, **options)
    link_to "Job##{message_id}", message_path(message_id), data: {turbo_frame: "home-content"}, **options
  end
end
