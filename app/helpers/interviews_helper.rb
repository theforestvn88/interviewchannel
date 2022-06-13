module InterviewsHelper
  def show_state(interview)
    (interview.finished? or interview.canceled?) ? "[#{interview.state.upcase}]" : "";
  end
end
