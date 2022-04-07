# frozen_string_literal:true

class UsersController < ApplicationController
    def suggest
        @users = User.suggest(params[:key])
        render layout: false
    end

    def profile
        redirect_to root_path unless user_signed_in?
        render_not_found unless @user = User.find_by(id: params[:id])
    end
end
