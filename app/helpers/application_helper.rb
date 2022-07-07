module ApplicationHelper
    class ActionView::Helpers::FormBuilder
        def limit_text_area(method, options = {})
            content = \
                "<div data-controller='helper' data-helper-limit-value='#{options[:limit]}'>" + 
                    text_area(method, options.merge({data: { helper_target: "limitInput", action: "keyup->helper#limitCharacters"}})) +
                    "<span data-helper-target='limitWarning'></span>" +
                "</div>"

            content.html_safe
        end
    end

    def filter_dropdown_tag(name, url, options, selected, other_selected = nil)
      tag.div(
        "data-controller": "card"
      ) { |dropdown|
        dropdown.div(
          "#{name}#{selected}",
          "data-action": "click->card#toggle click@window->card#lostFocus",
          class: "text-xs p-2 bg-gray-200 hover:cursor-pointer"
          ).concat(
            dropdown.div(
              "data-card-target": "card",
              class: "relative hidden"
            ) { |list|
              list.div(
                class: "absolute top-0 right-0 z-50 bg-gray-50 shadow-lg drop-shadow-lg border border-gray-300 w-52"
              ) { |items|
                options.each { |(k, v)|
                  items = items.concat(
                    button_to k, url, params: {filter: {"#{name.downcase}": v}.merge(other_selected)}, class: "w-full px-2 text-left hover:cursor-pointer hover:bg-gray-200"
                  )
                }
                items
              }
            }
          )
      }
    end

    def searching_tag(url, result_view, **options)
      %{
        <div data-controller="search" data-search-url-value="#{url}" data-search-resultview-value="#{result_view}" class="#{options[:class]}">

          <svg fill="#000000" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32" width="24px" height="24px"
              data-action="click->search#expand"
              data-search-target="icon"
          >
          <path d="M 5 5 L 5 27 L 27 27 L 27 5 Z M 7 7 L 25 7 L 25 25 L 7 25 Z M 15 10 C 12.25 10 10 12.25 10 15 C 10 17.75 12.25 20 15 20 C 15.992188 20 16.910156 19.722656 17.6875 19.21875 L 20.5625 22 L 21.9375 20.5625 L 19.125 17.8125 C 19.679688 17.007813 20 16.046875 20 15 C 20 12.25 17.75 10 15 10 Z M 15 12 C 16.667969 12 18 13.332031 18 15 C 18 16.667969 16.667969 18 15 18 C 13.332031 18 12 16.667969 12 15 C 12 13.332031 13.332031 12 15 12 Z"/>
          </svg>

          <div data-search-target="search" class="w-full flex justify-between z-10 hidden">
            <input data-search-target="input" data-action="input->search#query" class="w-full mr-1">
            <button data-action="search#collapse" class="text-lg px-1 hover:cursor-pointer hover:bg-red-400">✗</button>
          </div>
        </div>
      }.html_safe
    end
end
