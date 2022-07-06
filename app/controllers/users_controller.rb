# frozen_string_literal:true

class UsersController < ApplicationController
    before_action :require_user_signed_in, except: [:card]
    before_action :get_user, only: [:card, :private_chat, :send_private_chat, :add_contact, :remove_contact]
    before_action :allow_only_current_user, only: [:edit_profile, :update_profile, :add_watch_tag, :remove_watch_tag]

    def suggest
        if params[:key].empty?
            head :no_content
        else
            @users = User.suggest(params[:key]).first(6)
            render layout: false
        end
    end

    def profile
        render_not_found unless @user = User.find_by(id: params[:id])
    end

    def edit # edit user's cv only
        render layout: false
    end

    def edit_profile
        @tags = (current_user.watch_tags || "").split(" ").map {|t| t.gsub("#", "")}
        render layout: false
    end

    def update
      if current_user.update(user_params)
          render partial: "users/#{params[:partial]}", locals: {user: current_user, editable: true}, layout: false
      else
        @messager.send_error_flash(error: current_user.errors.first.full_message)
      end
    end

    def card
        render layout: false
    end

    def add_watch_tag
        if params[:watch_tag].present?
            user_curr_tags = (current_user.watch_tags || "").split(" ")
            param_tags = params[:watch_tag].map { |t| "##{t}"}

            @tags = (param_tags - user_curr_tags).map {|t| [t, @messager.count_by_tag(t)]}

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

    def private_chat
      @messager.establish_private_chat_form(to_user_id: @user.id)
      head :no_content
    end

    def send_private_chat
      @message = params[:message]
      @messager.send_private_chat_message(@message, to_user_id: @user.id)

      head :no_content
    end

    def add_contact
      @contact = Contact.new(user: current_user, friend: @user)
      respond_to do |format|
        begin
          if @contact.save
            format.turbo_stream { }
          else
            @messager.send_error_flash(error: @contact.errors.first.full_message)
            head :no_content
          end
        rescue
          @messager.send_error_flash(error: "Could Not Add Contact!")
          head :no_content
        end
      end
    end

    def remove_contact
      @contact = Contact.find_by(user: current_user, friend: @user)
      respond_to do |format|
        if @contact && @contact.destroy
          format.turbo_stream { }
        else
          @messager.send_error_flash(error: "Could Not Remove Contact!")
          head :no_content
        end
      end
    end

    private

        def allow_only_current_user
            redirect_to root_path unless current_user.id == params[:id].to_i
        end

        include UsersHelper
        def user_params
            _user_params = params.require(:user).permit(:cv, *social_support, :watch_tags, tags: [])
            _social = _user_params.extract!(*social_support)
            _user_params[:social] = (current_user.social || {}).merge(_social)
            _user_params
        end

        def get_user
            @user = User.find_by(id: params[:id])
        end
end
