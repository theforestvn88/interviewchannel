class InterviewStreamsChannel < Turbo::StreamsChannel
  def receive(data)
    puts "SERVER interview streams receive #{data}"

    interview_id = data["id"]
    interview = Interview.new(id: interview_id)
    
    broadcast_update_interview(interview, data)
  end

  private def broadcast_update_interview(interview, update_data)
    ActionCable.server.broadcast interview_stream_name(interview), update_data
  end

  private def interview_stream_name(interview)
    InterviewStreamsChannel.send(:stream_name_from, interview)
  end
end