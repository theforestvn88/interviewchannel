class MessagesController < ApplicationController
  before_action :ensure_user_signed_in
  before_action :set_message, only: %i[ show edit update destroy apply submit_apply ]

  # GET /messages or /messages.json
  def index
    @messages = Messager.new(current_user, current_user.curr_timezone).recently(params[:tag])
  end

  def query
    @messages = Messager.new(current_user, current_user.curr_timezone).recently(params[:tag])
    respond_to do |format|
      format.html { }
      format.json { }
      format.turbo_stream { }
    end
  end

  # GET /messages/1 or /messages/1.json
  def show
    render layout: false
  end

  # GET /messages/new
  def new
    @message = Message.new
    render layout: false
  end

  # GET /messages/1/edit
  def edit
    render layout: false
  end

  # POST /messages or /messages.json
  def create
    @message = Message.new(message_params.merge({user_id: current_user.id, expired_at: 1.hour.from_now}))

    respond_to do |format|
      if @message.save
        Messager.new(current_user, current_user.curr_timezone).increase_then_broadcast_counter(@message)

        format.html { redirect_to message_url(@message), notice: "Message was successfully created." }
        format.json { render :show, status: :created, location: @message }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /messages/1 or /messages/1.json
  def update
    respond_to do |format|
      if @message.update(message_params)
        format.html { redirect_to message_url(@message), notice: "Message was successfully updated." }
        format.json { render :show, status: :ok, location: @message }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /messages/1 or /messages/1.json
  def destroy
    @message.destroy
    Messager.new(current_user, current_user.curr_timezone).decrease_then_broadcast_counter(@message)
  end

  # GET /apply
  def apply
    render layout: false
  end

  # POST /apply
  def submit_apply
    applying = Applying.new(message: @message, candidate: current_user, intro: params[:intro])

    if applying.save
      # send private message first
      Messager.new(current_user, current_user.curr_timezone)
        .send_private_message(to_user_id: @message.user_id, partial: "messages/applying_message", locals: {applying: applying})

      # send update applying counter
      @message.touch(time: Time.now.utc)
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_message
      @message = Message.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def message_params
      params.require(:message).permit(:channel, :content, :expired_at, :user_id)
    end
end
