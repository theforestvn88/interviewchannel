class InterviewStreamsChannel < Turbo::StreamsChannel
  def receive(data)
    puts "SERVER interview streams receive #{data}"

    interview_id = data["id"]
    user_id = data["user_id"]
    interview = Interview.new(id: interview_id)

    lock = InterviewRepo.get_lock(interview_id)
    if !lock || lock == user_id # TODO: mutex ?
      InterviewRepo.set_lock(interview_id, user_id, expires_at: 3.seconds.from_now)
      InterviewStreamsChannel.broadcast_update_interview(interview, data.merge(:"lock" => user_id))
      save_code(interview_id, data["file"]) if data["file"]
      handle_command(interview_id, user_id, data["command"]) if data["command"]
    end
  end

  def self.broadcast_update_interview(interview, update_data)
    ActionCable.server.broadcast stream_name_from(interview), update_data
  end

  private def interview_stream_name(interview)
    InterviewStreamsChannel.send(:stream_name_from, interview)
  end

  private def save_code(interview_id, code_file)
    return unless code_file["path"] && code_file["code"]
    
    CodeRepo.save_code(interview_id: interview_id, path: code_file["path"], code: code_file["code"], expires_at: 3.hours.from_now)
  end

  private def handle_command(interview_id, user_id, command)
    cmd, *params = command.split(" ")

    case cmd
    when "run"
      InterviewRepo.set_lock(interview_id, user_id, expires_at: 2.minutes.from_now)
      file_path, pos_start, pos_end = *params
      CodeRunJob.perform_later interview_id, user_id, file_path, pos_start.to_i, pos_end.to_i
    end
  end
end
