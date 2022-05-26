# frozen_string_literal:true

class UsersController < ApplicationController
    before_action :require_user_signed_in, except: [:card]
    before_action :get_user, only: [:card]
    before_action :allow_only_current_user, only: [:edit_profile, :update_profile, :add_watch_tag, :remove_watch_tag]

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
        @tags = current_user.watch_tags.split(" ").map {|t| t.gsub("#", "")}
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
        render layout: false
    end

    def add_watch_tag
        if params[:watch_tag].present?
            user_curr_tags = (current_user.watch_tags || "").split(" ")
            param_tags = params[:watch_tag].map { |t| "##{t}"}

            messager = Messager.new(current_user, current_user.curr_timezone)
            @tags = (param_tags - user_curr_tags).map {|t| [t, messager.count_by_tag(t)]}

            if @tags.present?
                current_user.watch_tags = (user_curr_tags + @tags.map(&:first)).join(" ")
                current_user.save
            end

            respond_to do |format|
                format.turbo_stream { }
            end
        else
            respond_to do |format|
                format.turbo_stream { head :no_content }
            end
        end
    end

    def remove_watch_tag
        @remove_tag = params[:tag]
        current_user.watch_tags = current_user.watch_tags.split(" ").reject { |t| t.downcase == @remove_tag.downcase }.join(" ")
        current_user.save

        respond_to do |format|
            format.turbo_stream { }
        end
    end

    private

        def allow_only_current_user
            redirect_to root_path unless current_user.id == params[:id].to_i
        end

        def user_params
            params.require(:user).permit(:cv, :watch_tags, tags: [])
        end

        def get_user
            @user = User.find_by(id: params[:id])
        end
end
