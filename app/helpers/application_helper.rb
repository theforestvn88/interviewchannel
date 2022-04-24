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
end
