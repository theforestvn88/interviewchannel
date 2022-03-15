# frozen_string_literal: true
# scheduler of user

class Scheduler
    include Query

    def initialize(user)
        @user = user
    end    
end
