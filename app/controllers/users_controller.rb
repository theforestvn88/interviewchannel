# frozen_string_literal:true

class UsersController < ApplicationController
    def suggest
        @users = User.suggest(params[:key])
        render layout: false
    end
end
