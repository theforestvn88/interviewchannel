module UsersHelper
  include SocialLinks

  def user_card_tag(user = nil, user_id: nil, user_name: nil, format: "%s", **options)
    user_id ||= user&.id 
    user_name ||= user&.name
    
    tag.span(
      **options,
      "data-controller": "card",
      "data-action": "mouseenter->card#show mouseleave->card#delayHide mousedown->card#hide",
      "data-card-url-value": card_user_path(id: user_id)
    ) { |_|
      link_to user_name, profile_user_path(id: user_id), data: {turbo: false}
    }
  end

  def contacts_list_frame_id(user)
    "user-#{user.id}-contacts"
  end
end
