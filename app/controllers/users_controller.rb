# frozen_string_literal:true

class UsersController < ApplicationController
    before_action :ensure_user_signed_in, only: [:profile, :edit_profile, :update_profile, :card]
    before_action :allow_only_current_user, only: [:edit_profile, :update_profile]

    def suggest
        @users = User.suggest(params[:key])
        render layout: false
    end

    def profile
        render_not_found unless @user = User.find_by(id: params[:id])
    end

    def edit
        render layout: false
    end

    def edit_tags
        render layout: false
    end

    def update
        if current_user.update(user_params)
            render partial: "users/#{params[:partial]}", locals: {user: current_user}, layout: false
        else
            render :edit
        end
    end

    def card
        @user = User.find_by(id: params[:id])
        render layout: false
    end

    private

        def allow_only_current_user
            redirect_to root_path unless current_user.id == params[:id].to_i
        end

        def user_params
            params.require(:user).permit(:cv, :watch_tags)
        end
end
