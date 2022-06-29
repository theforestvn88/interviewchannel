module UsersHelper
  include SocialLinks

  def user_card_tag(user, **options)
    tag.span(
      **options,
      "data-controller": "card",
      "data-action": "mouseenter->card#show mouseleave->card#hide mousedown->card#hide",
      "data-card-url-value": card_user_path(user)
    ) { |_|
      link_to user.name, profile_user_path(user), data: {turbo: false}
    }
  end
end
