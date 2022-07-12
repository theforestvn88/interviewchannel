# frozen_string_literal: true

class RepliesController < ApplicationController
    before_action :require_user_signed_in
    before_action :set_applying

    def new
        @reply = Reply.new
        render layout: false
    end

    def create
        @reply = Reply.new reply_params.merge({applying_id: @applying.id, user_id: current_user.id})
        @cc = params[:cc] || []
        @reply.content += "- cc: " + User.where(id: @cc).pluck(:name).join(", ") if @cc.present?

        if @reply.save
            @messager.send_private_reply(@applying, @reply, @cc, locals: {timezone: current_user.curr_timezone})
        end

        respond_to do |format|
            format.turbo_stream { }
        end
    end

    def previous
        @replies = @applying.replies.where(created_at: ...DateTime.parse(params[:date])).last(6)
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

