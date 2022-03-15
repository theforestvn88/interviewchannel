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
    
        def today(*roles)
            today = Time.now.utc
            as_role(*roles)
                .by_time(today.beginning_of_day, today.end_of_day)
        end
    
        def this_week(*roles)
            today = Time.now.utc
            as_role(*roles)
                .by_time(today.beginning_of_week, today.end_of_week)
        end
    
        def this_month(*roles)
            today = Time.now.utc
            as_role(*roles)
                .by_time(today.beginning_of_month, today.end_of_month)
        end
    
        def previous_day(num, *roles)
            _prev_day = num.day.ago.utc
            as_role(*roles)
                .by_time(_prev_day.beginning_of_day, _prev_day.end_of_day)
        end
    
        def previous_week(num, *roles)
            _pre_week = num.week.ago.utc
            as_role(*roles)
                .by_time(_pre_week.beginning_of_week, _pre_week.end_of_week)
        end
    
        def previous_month(num, *roles)
            _prev_month = num.month.ago.utc
            as_role(*roles)
                .by_time(_prev_month.beginning_of_month, _prev_month.end_of_month)
        end
    
        def next_day(num, *roles)
            _next_day = num.day.from_now.utc
            as_role(*roles)
                .by_time(_next_day.beginning_of_day, _next_day.end_of_day)
        end
    
        def next_week(num, *roles)
            _next_week = num.week.from_now.utc
            as_role(*roles)
                .by_time(_next_week.beginning_of_week, _next_week.end_of_week)
        end
    
        def next_month(num, *roles)
            _next_month = num.month.from_now.utc
            as_role(*roles)
                .by_time(_next_month.beginning_of_month, _next_month.end_of_month)
        end
    end
end
