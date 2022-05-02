# frozen_string_literal: true

class ApplyingsController < ApplicationController
    before_action :ensure_user_signed_in
    before_action :set_message, only: [:new, :create]

    # GET /applying/new
    def new
        @applying = Applying.new
        render layout: false
    end

    # POST /applyings
    def create
        applying = Applying.new applying_params.merge({message_id: @message.id, candidate_id: current_user.id, interviewer_id: @message.user_id})

        if applying.save
            # send private message first
            Messager.new(current_user, current_user.curr_timezone)
                .send_private_message(to_user_id: @message.user_id, partial: "applyings/applying", locals: {applying: applying, owner: current_user})
        end

        head :no_content
    end

    private

        def set_message
            @message = Message.find(params[:message_id])
        end

        def applying_params
            params.require(:applying).permit(:intro)
        end
end
