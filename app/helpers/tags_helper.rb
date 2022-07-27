module TagsHelper
  def tag_link(tag_name)
      _tag = tag_name.gsub("#", "")
      link_to by_tag_messages_path(tag: tag_name), data: {turbo_frame: "home-content"} do
          tag.span("#", class: "font-light #{_tag} hover:cursor-pointer hover:underline")
            .concat(
              tag.span _tag, class: "font-light"
            )
      end
  end
end
