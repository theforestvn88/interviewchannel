class InterviewStreamsChannel < Turbo::StreamsChannel
  def receive(data)
    puts "SERVER interview streams receive #{data}"
  end
end