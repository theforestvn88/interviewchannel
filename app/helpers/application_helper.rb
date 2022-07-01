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
end
