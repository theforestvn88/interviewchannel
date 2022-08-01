# frozen_string_literal: true

module SearchParser

    def parse(field, search_term)
        unless search_term.blank?
            case field
            when "id", :id
                parse_int(field, search_term)
            else
                if check_int(field, search_term)
                    parse_int(field, search_term)
                elsif date = check_time(field, search_term)
                    parse_time(field, date)
                else
                    "#{field} ILIKE '%#{search_term}%'"
                end
            end
        end
    end

    def parse_int(field, search_term)
        "#{field} = '#{search_term}'"
    end

    def check_int(field, search_term)
        int_param = begin 
            Integer(search_term)
        rescue
            nil
        end 
    end

    def check_time(field, search_term)
        begin
            date = DateTime.parse(search_term)
        rescue
            nil
        end
    end

    def parse_time(field, date)
        "#{field} BETWEEN '#{date.beginning_of_day}' AND '#{date.end_of_day}'"
    end

    def parse_search_action(action_search, record)
        return if action_search.nil?

        clazz_name = record.class.name.downcase
        action_search.transform_values do |value|
            if (parts = value.to_s.split(".")).size > 1 && parts.first == clazz_name
                record.send(parts.last)
            else
                value
            end
        end
    end
end