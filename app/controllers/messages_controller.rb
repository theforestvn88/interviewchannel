class MessagesController < ApplicationController
  before_action :ensure_user_signed_in
  before_action :set_message, only: %i[ show edit update destroy ]

  # GET /messages or /messages.json
  def index
    @messages = Messager.new(current_user, current_user.curr_timezone).recently(params[:tag])
  end

  def query
    offset_time = DateTime.parse(params[:offset]) if params[:offset]
    limit = Messager::Query::PAGE

    @tag = params[:tag]
    messager = Messager.new(current_user, current_user.curr_timezone)

    case @tag
    when "#private"
      @messages = messager.private_messages(current_user, offset_time: offset_time, limit: limit)
      @template = "messages/private"
      @partial = "applyings/applying"
    when "#public"
      @messages = messager.own_by_me(offset_time: offset_time, limit: limit)
    else
      @messages = messager.recently(@tag, offset_time: offset_time, limit: limit)
    end
    
    @template ||= "messages/index"
    @partial ||= "messages/message"
    @next_offset = @messages.size >= Messager::Query::PAGE ? @messages.last.updated_at : nil
    @locals ||= {messages: @messages, tag: @tag, offset: @next_offset, owner: current_user}

    respond_to do |format|
      format.html { }
      format.json { }
      format.turbo_stream { }
    end
  end

  # GET /messages/1 or /messages/1.json
  def show
    @message.update_columns views: @message.increment(:views, 1).views
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_message
      @message = Message.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def message_params
      params.require(:message).permit(:channel, :content, :expired_at, :user_id, tags: [])
    end
end
