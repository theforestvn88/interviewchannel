module TagsHelper
  def tag_link(tag_name)
      _tag = format_tag(tag_name)
      link_to by_tag_messages_path(tag: tag_name), data: {turbo_frame: "home-content"} do
          tag.span("#", class: "font-light #{_tag} hover:cursor-pointer hover:underline")
            .concat(
              tag.span _tag, class: "font-light"
            )
      end
  end

  def format_tag(tag)
    tag.strip.gsub(" ", "-").downcase
  end
end
