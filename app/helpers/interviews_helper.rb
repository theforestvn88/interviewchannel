module InterviewsHelper
  def show_state(interview)
    (interview.finished? or interview.canceled?) ? "[#{interview.state.upcase}]" : "";
  end

  def interview_fuid(interview, format: :long)
    case format
    when :long
      show_state(interview) + "job##{interview.job_id}round##{interview.round}@#{interview.candidate.name}<#{interview.candidate.email}>"
    when :short
      "job##{interview.job_id}round##{interview.round}@u#{interview.candidate_id}"
    end
  end

  def interview_link_tag(interview, **options)
    tag.div(
      **options,
      "data-controller": "card",
      "data-action": "mouseenter->card#show mouseleave->card#hide mousedown->card#hide",
      "data-card-url-value": card_interview_path(interview)
    ) { |_|
      link_to "interview##{interview.id}@round#{interview.round}.", interview_path(interview), data: {turbo_frame: "home-content"}, class: "bg-red-200 font-bold text-blue-600 ml-1"
    }
  end
end
