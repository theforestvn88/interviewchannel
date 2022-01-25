module InterviewsHelper
  def interview_stream(*streamables, **attributes, &block)
    attributes[:channel] = attributes[:channel]&.to_s || "InterviewStreamsChannel"
    attributes[:"signed-stream-name"] = Turbo::StreamsChannel.signed_stream_name(streamables)

    tag.interview_stream(**attributes) { block.call }
  end
end
