# frozen_string_literal: true

class Scheduler
    module Query
        def as_role(*roles)
            by_role = Interview.send("as_#{roles.pop}".to_sym, @user)
            roles.each do |role|
                by_role = by_role.or(Interview.send("as_#{role}".to_sym, @user))
            end
            by_role
        end
    
        def day(target_date, *roles, keyword: nil)
            as_role(*roles)
                .by_time(target_date.beginning_of_day, target_date.end_of_day)
                .by_keyword(keyword)
        end

        def today(*roles, keyword: nil)
            day(Time.now.utc, *roles, keyword: keyword)
        end

        def previous_day(target_date, *roles, keyword: nil)
            _prev_day = target_date + -1.day
            day(_prev_day, *roles, keyword: keyword)
        end

        def next_day(target_date, *roles, keyword: nil)
            _next_day = target_date + 1.day
            day(_next_day, *roles, keyword: keyword)
        end

        def week(aday_in_week, *roles, keyword: nil)
            as_role(*roles)
                .by_time(aday_in_week.beginning_of_week, aday_in_week.end_of_week)
                .by_keyword(keyword)
        end

        def this_week(*roles, keyword: nil)
            today = Time.now.utc
            week(today, *roles, keyword: keyword)
        end
    
        def previous_week(aday_in_week, *roles, keyword: nil)
            _pre_week = aday_in_week + -1.week
            week(_pre_week, *roles, keyword: keyword)
        end

        def next_week(aday_in_week, *roles, keyword: nil)
            _next_week = aday_in_week + 1.week
            week(_next_week, *roles, keyword: keyword)
        end

        def month(aday_in_month, *roles, keyword: nil)
            as_role(*roles)
                .by_time(aday_in_month.beginning_of_month, aday_in_month.end_of_month)
                .by_keyword(keyword)
        end

        def this_month(*roles, keyword: nil)
            today = Time.now.utc
            month(today, *roles, keyword: keyword)
        end
    
        def previous_month(aday_in_month, *roles, keyword: nil)
            _prev_month = aday_in_month + -1.month
            month(_prev_month, *roles, keyword: keyword)
        end
    
        def next_month(aday_in_month, *roles, keyword: nil)
            _next_month = aday_in_month + 1.month
            month(_next_month, *roles, keyword: keyword)
        end
    end
end
