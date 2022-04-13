# frozen_string_literal: true

class Messager
    include Query

    def initialize(user = nil)
        @user = user
    end
end
