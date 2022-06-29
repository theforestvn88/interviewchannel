module InterviewsHelper
  def show_state(interview)
    (interview.finished? or interview.canceled?) ? "[#{interview.state.upcase}]" : "";
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
