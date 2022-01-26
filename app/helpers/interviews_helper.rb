module InterviewsHelper
  def interview_stream(*interviews, **attributes, &block)
    attributes[:channel] = attributes[:channel]&.to_s || "InterviewStreamsChannel"
    attributes[:"signed-stream-name"] = Turbo::StreamsChannel.signed_stream_name(interviews)
    attributes[:"interview-id"] = interviews.first.id
    attributes[:"user"] = SecureRandom.hex(6) # TODO: replace by User model

    tag.interview_stream(**attributes) { block.call }
  end
end
