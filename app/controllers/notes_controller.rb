# frozen_string_literal: true

class NotesController < ApplicationController
  before_action :require_user_signed_in
  before_action :set_interview

  def new
    @note = Note.new(interview_id: @interview.id, user_id: current_user.id)
    render layout: false
  end

  def create
    cc = User.where(id: params[:forward]).pluck(:name).map {|x| "@#{x}"}.join(", ")
    @note = Note.create!(note_params.merge(cc: "cc: #{cc}", user_id: current_user.id, interview_id: @interview.id))
    respond_to do |format|
      format.turbo_stream { }
    end
  end

  private def set_interview
    @interview = Interview.find(params[:interview_id])
  end

  private def note_params
    params.require(:note).permit(:content)
  end
end
