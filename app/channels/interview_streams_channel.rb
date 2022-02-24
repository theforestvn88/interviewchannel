class InterviewStreamsChannel < Turbo::StreamsChannel
  def receive(data)
    puts "SERVER interview streams receive #{data}"

    interview_id = data["id"]
    interview = Interview.new(id: interview_id)
    
    InterviewStreamsChannel.broadcast_update_interview(interview, data)

    if code_file = data["file"]
      CodeRepo.save_code(interview_id: interview_id, path: code_file["path"], code: code_file["code"], expires_at: 3.hours.from_now)
    end

    if command = data["command"]
      cmd, *params = command.split(" ")

      case cmd
      when "run"
        file_path, pos_start, pos_end = *params
        CodeRunJob.perform_later interview_id, file_path, pos_start.to_i, pos_end.to_i
      end
    end
  end

  def self.broadcast_update_interview(interview, update_data)
    ActionCable.server.broadcast stream_name_from(interview), update_data
  end

  private def interview_stream_name(interview)
    InterviewStreamsChannel.send(:stream_name_from, interview)
  end
end