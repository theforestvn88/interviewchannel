module UsersHelper
  include SocialLinks

  def user_card_tag(user, format: "%s", **options)
    tag.span(
      **options,
      "data-controller": "card",
      "data-action": "mouseenter->card#show mouseleave->card#delayHide mousedown->card#hide",
      "data-card-url-value": card_user_path(user)
    ) { |_|
      link_to format % user.name, profile_user_path(user), data: {turbo: false}
    }
  end
end
