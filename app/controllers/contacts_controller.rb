# frozen_string_literal:true

class ContactsController < ApplicationController
  before_action :require_user_signed_in
  before_action :set_contact, only: %i[ edit update destroy ]

  def new
    friend = User.find( params[:friend_id])
    @contact = Contact.new(user_id: current_user.id, friend_id: friend.id, custom_name: "@#{friend.name}")
    render layout: false
  end

  def edit
    render layout: false
  end

  def create
    @contact = Contact.new(contact_params)
    respond_to do |format|
      begin
        @contact.save!
        format.turbo_stream { }
      rescue
        @messager.send_error_flash(error: "Could Not Add Contact!")
        head :no_content
      end
    end
  end

  def update
    respond_to do |format|
      begin
        @contact.update!(contact_params)
        format.turbo_stream { }
      rescue
        @messager.send_error_flash(error: "Could Not Update Contact!")
      end
    end
  end

  def destroy
    @contact.destroy

    respond_to do |format|
      format.turbo_stream { }
    end
  end

  private

    def contact_params
      params.require(:contact).permit(:custom_name, :user_id, :friend_id)
    end

    def set_contact
      @contact = Contact.find_by(user_id: current_user.id, friend_id: params[:friend_id])
    end
end
