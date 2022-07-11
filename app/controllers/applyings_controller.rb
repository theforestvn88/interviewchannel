# frozen_string_literal: true

class ApplyingsController < ApplicationController
    before_action :require_user_signed_in
    before_action :set_message, only: [:new, :create]
    before_action :set_applying, except: [:new, :create]

    # GET /applying/new
    def new
        @applying = Applying.new
        render layout: false
    end

    def show
    end

    # POST /applyings
    def create
        if @message.expired?
            @messager.send_error_flash(error: "This message is expired !!!")
            head :no_content
        else
            applying = Applying.new applying_params.merge({message_id: @message.id, candidate_id: current_user.id, interviewer_id: @message.user_id})
            if applying.save
                @messager.send_private_message( # send private message first
                    to_user_id: @message.user_id, 
                    partial: "applyings/applying", 
                    locals: {applying: applying, user: current_user, timezone: current_user.curr_timezone},
                    flash: "#{current_user.name} applied the job message ##{@message.id}"
                )
                .broadcast_replace(@message) # broadcast due to counter-cache update

                Contact.hit(applying.candidate_id, applying.interviewer_id)

                redirect_to message_url(@message)
            else
                @messager.send_model_error_flash(applying)
                head :no_content
            end
        end
    end

    def close
        if @applying.control_by?(current_user)
            @applying.update_columns open: false

            @messager.create_and_send_private_reply(
              applying: @applying, 
              sender_id: current_user.id,
              type: Reply::APPLY_TYPE, 
              partial: "replies/close_applying_reply", 
              locals: { timezone: current_user.curr_timezone },
              flash: "")

            render layout: false
        else
            head :no_content
        end
    end
    
    def open
        if @applying.control_by?(current_user)
            @applying.update_columns open: true
            render layout: false
        else
            head :no_content
        end
    end

    private

        def set_message
            @message = Message.find(params[:message_id])
        end

        def applying_params
            params.require(:applying).permit(:intro)
        end

        def set_applying
            @applying = Applying.find(params[:id])
        end
end
