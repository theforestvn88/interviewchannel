# frozen_string_literal:true

class ContactsController < ApplicationController
  before_action :ensure_user_signed_in
  before_action :set_contact, only: %i[ edit update destroy ]

  def paging
    @contacts, @next_offset = BookMark.recently_contacts(current_user, params[:offset], params[:limit])
    current_user.recently_contacts.offset(params[:offset].to_i).limit(params[:limit] || PAGE)
    @next_offset = @contacts.size >= PAGE ? params[:offset].to_i + PAGE : nil

    respond_to do |format|
      format.turbo_stream { }
    end
  end

  def search
    @contacts = BookMark.search_contacts(current_user, params[:key])

    render layout: false
  end

  def new
    unless Contact.exists?(user_id: current_user.id, friend_id: params[:friend_id])
      friend = User.find(params[:friend_id])
      @contact = Contact.new(user_id: current_user.id, friend_id: friend.id, custom_name: "@#{friend.name}")
      render layout: false
    else
      @messager.send_error_flash(error: "The Contact already Exists!")
      head :no_content
    end
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
        @contact.update!(contact_params.extract!(:custom_name))
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

  PAGE = 10

  private

    def contact_params
      params.require(:contact).permit(:custom_name, :user_id, :friend_id)
    end

    def set_contact
      @contact = Contact.find(params[:id])
    end
end
