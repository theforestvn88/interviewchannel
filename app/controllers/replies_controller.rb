# frozen_string_literal: true

class RepliesController < ApplicationController
    before_action :ensure_user_signed_in
    before_action :set_applying

    def new
        @reply = Reply.new
        render layout: false
    end

    def create
        @reply = Reply.new reply_params.merge({applying_id: @applying.id, user_id: current_user.id})

        if @reply.save
            Messager.new(current_user, current_user.curr_timezone)
                .send_private_reply(@applying, @reply)
        end

        respond_to do |format|
            format.turbo_stream { }
        end
    end

    private

        def set_applying
            @applying = Applying.find(params[:applying_id])
        end

        def reply_params
            params.require(:reply).permit(:content)
        end
end

