class MessagesController < ApplicationController
  before_action :ensure_user_signed_in, except: %i[ index query by_tag new_filter filter show ]
  before_action :set_message, only: %i[ show edit update destroy ]

  # GET /messages or /messages.json
  def index
    @messages = @messager.recently(params[:tag])
  end

  def query
    offset_time = DateTime.parse(params[:offset]) if params[:offset]
    limit = Messager::Query::PAGE

    @template = "messages/index"

    @tags = params[:tag].split(",")
    case @tags.first
    when "#inbox"
      @messages = @messager.inbox_messages(current_user, filter: params[:filter] || {}, offset_time: offset_time, limit: limit)
      @jobids, @users = PrivateMessageRepo.filter by_user: current_user
      @filter_jobid = params.dig(:filter, :job)
      @filter_userid = params.dig(:filter, :user, :id)
      @filter_username = params.dig(:filter, :user, :name)
      @template = "messages/inbox"
    when "#sent"
      @messages = @messager.own_by_me(offset_time: offset_time, limit: limit)
    else
      @messages = @messager.recently(@tags, offset_time: offset_time, sort_by: Array(params[:sort_by]), limit: limit)
    end

    @next_offset = @messages.size >= Messager::Query::PAGE ? @messages.last.updated_at : nil
    @filter_tags = join_tags
    @locals ||= {
      messages: @messages, 
      filter_tags: @filter_tags, 
      offset: @next_offset, 
      owner: current_user, 
      user: current_user,
      timezone: current_user&.curr_timezone || "UTC"
    }

    respond_to do |format|
      format.turbo_stream { }
    end
  end

  def by_tag
    @tags = params[:tag] || "#all"
    @messages = @messager.recently(@tags, limit: Messager::Query::PAGE)
    @next_offset = @messages.size >= Messager::Query::PAGE ? @messages.last.updated_at : nil
    @locals = {
      messages: @messages, 
      filter_tags: @tags,
      offset: @next_offset, 
      timezone: current_user&.curr_timezone || "UTC"
    }
  end

  def new_filter
    render layout: false
  end

  def filter
    @tags = params[:tags] || "#all"
    @messages = @messager.recently(@tags, limit: Messager::Query::PAGE)
    @next_offset = @messages.size >= Messager::Query::PAGE ? @messages.last.updated_at : nil
    @locals ||= {
      messages: @messages, 
      tags: @tags,
      filter_tags: join_tags,
      offset: @next_offset, 
      timezone: current_user&.curr_timezone || "UTC"
    }

    respond_to do |format|
      format.turbo_stream { }
    end
  end

  def similar
    @channel = params[:channel]
    @messages = Message.similarity_tags(@channel.split(' ')).order(views: :desc).first(7).reject {|m| m.id == params[:id].to_i}

    if @messages.blank?
      head :no_content
    else
      render layout: false
    end
  end

  def by_me
    head :no_content unless @user = User.find_by(id: params[:user])

    offset = params[:offset].to_i
    @messages = @user.sent_messages.offset(offset).limit(Messager::Query::PAGE)
    @next_offset = @messages.size >= Messager::Query::PAGE ? (offset + @messages.size) : nil
    @locals = {
      messages: @messages, 
      filter_tags: @tags,
      offset: @next_offset, 
      timezone: current_user&.curr_timezone || "UTC"
    }
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
    RateLimiter.new(
      current_user, 
      :created_messages, 
      SettingRepo.fetch("rate_limiter.message_limit_per_day"), 
      :day_exceeded, 
      expires_at: today_in_curr_timezone.next_day.beginning_of_day.utc
    ).check!

    respond_to do |format|
      @message = @messager.create_message(message_params)
      format.turbo_stream
    end
  end

  # PATCH/PUT /messages/1 or /messages/1.json
  def update
    respond_to do |format|
      result = if params.has_key?(:close) then
        @message.close!
      else
        @message.update(message_params)
      end

      if result
        format.html { redirect_to message_url(@message) }
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
    @messager.decrease_then_broadcast_counter(@message)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_message
      @message = Message.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def message_params
      params.require(:message).permit(:title, :channel, :content, :expired_at, :user_id, :auto_reply_enable, :auto_reply, tags: [])
    end

    def join_tags
      @tags&.join(",")
    end
end
