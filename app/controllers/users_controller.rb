# frozen_string_literal:true

class UsersController < ApplicationController
    before_action :require_user_signed_in, except: [:card, :private_chat]
    before_action :ensure_user_signed_in, only: [:private_chat, :send_private_chat]
    before_action :get_user, only: [:card, :private_chat, :send_private_chat]
    before_action :allow_only_current_user, only: [:edit_profile, :update_profile, :add_watch_tag, :remove_watch_tag]

    def suggest
        if params[:key].empty?
            head :no_content
        else
            contacts = current_user.contacts.includes(:friend).suggest(params[:key]).first(6)
            if contacts.present?
                @users = contacts.map do |contact|
                    _user = contact.friend
                    _user.custom_name = contact.custom_name if _user.name != contact.custom_name[1..]
                    _user
                end
            else
                @users = User.suggest(params[:key].strip).first(6)
            end

            render layout: false
        end
    end

    def profile
        render_not_found unless @user = User.find_by(id: params[:id])

        @messages = @user.sent_messages.first(Messager::Query::PAGE)
        @next_offset = @messages.size >= Messager::Query::PAGE ? Messager::Query::PAGE : nil
    end

    def edit # edit user's cv only
        render layout: false
    end

    def edit_profile
        @tags = current_user.split_tags
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
        if (param_tags = get_watch_tags).present?
            user_curr_tags = current_user.split_tags
            @tags = (param_tags - user_curr_tags).map {|t| [t, @messager.count_by_tag(t)]}

            if @tags.present?
                current_user.tags = user_curr_tags + @tags.map(&:first)
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
        current_user.tags = current_user.split_tags.reject { |t| t.downcase == @remove_tag.downcase }
        current_user.save

        respond_to do |format|
            format.turbo_stream { }
        end
    end

    def private_chat
      @messager.establish_private_chat_form(to_user_id: @user.id)
      Contact.hit(current_user.id, @user.id)
      
      head :no_content
    end

    def send_private_chat
      @message = params[:message]
      @messager.send_private_chat_message(@message, to_user_id: @user.id)

      head :no_content
    end

    private

        def allow_only_current_user
            redirect_to root_path unless current_user.id == params[:id].to_i
        end

        include UsersHelper
        def user_params
            _user_params = params.require(:user).permit(:image, :name, :brief_intro, *social_support, :watch_tags, :cv, tags: [])
            _social = _user_params.extract!(*social_support)
            _user_params[:social] = (current_user.social || {}).merge(_social)
            _user_params
        end

        def get_user
            @user = User.find_by(id: params[:id])
        end

        def get_watch_tags
            param_tags = []
            param_tags = param_tags + params[:watch_tags].select(&:present?).map(&:downcase) if params[:watch_tags].present?
            param_tags = param_tags + params[:watch_lang_tags].select(&:present?).map(&:downcase) if params[:watch_lang_tags].present?
            param_tags = param_tags + params[:watch_framework_tags].select(&:present?).map(&:downcase) if params[:watch_framework_tags].present?
            param_tags = param_tags + params[:watch_other_tags].select(&:present?).map(&:downcase) if params[:watch_other_tags].present?

            param_tags.reject {|t| t.blank? }
        end
end
