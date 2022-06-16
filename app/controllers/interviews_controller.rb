class InterviewsController < ApplicationController
  before_action :ensure_user_signed_in
  before_action :set_interview, only: %i[ show room edit update destroy card confirm ]
  before_action :convert_time, only: %i[ create update ]

  # GET /interviews or /interviews.json
  def index
    @interviews = Interview.all
  end

  # GET /interviews/1 or /interviews/1.json
  def show
    unless @interview && @interview.involve?(current_user)
      redirect_to root_path
    end

    messager = Messager.new(current_user, current_user.curr_timezone)
    @private_channel = messager.private_channel(current_user)
  end

  def room
    unless @interview && @interview.involve?(current_user) && @interview.started?
      redirect_to root_path
    end
  end

  # GET /interviews/new
  def new
    @interview = Interview.new
    @interview.candidate = User.find_by(id: params[:candidate_id])
    @interview.start_time = Time.now.utc
    @interview.end_time = Time.now.utc + 1.hour
    
    if params[:applying_id]
      @interview.applying = Applying.find_by(id: params[:applying_id])
      @interview.title = "Job##{@interview.applying.message_id} Interview for @#{@interview.applying.candidate.name}"
      
      last_interview = Interview.where(applying_id: @interview.applying.id).last
      @interview.round = (last_interview&.round || 0) + 1
      @interview.head_id = last_interview&.head_id || last_interview&.id
    else
      @interview.round = 1
      @interview.head_id = nil
    end
  end

  # GET /interviews/1/edit
  def edit
    render layout: false
  end

  # POST /interviews or /interviews.json
  def create
    @interview = Interview.new(interview_params)
    @interview.owner = current_user

    respond_to do |format|
      if @interview.save
        format.html { redirect_to interview_url(@interview), notice: "Interview was successfully created." }
        format.json { render :show, status: :created, location: @interview }
        format.turbo_stream { }

        messager = Messager.new(current_user, current_user.curr_timezone)

        if applying = @interview.applying
          messager.create_and_send_private_reply(
            applying: applying, 
            sender_id: current_user.id, 
            partial: "interviews/private_reply", 
            locals: {interview: @interview, date: @interview.start_time.in_time_zone(current_user.curr_timezone).strftime('%FT%R')},
            flash: "I scheduled the interview. Good Luck!")
        end

        (@interview.interviewers + [@interview.candidate]).uniq.each do |user|
          presenter = CalendarPresenter.new(Scheduler.new(user))
          timezone = user.curr_timezone
          tz_offset = ActiveSupport::TimeZone[timezone].formatted_offset
          interview_date = @interview.start_time.in_time_zone(timezone)

          messager.send_private_interview(
            @interview,
            user,
            action: :replace,
            target: "#{interview_date.strftime('%d-%b')}-#{tz_offset}", 
            partial: "interviews/mini_day",
            locals: {interview_date: interview_date, today: Time.now.in_time_zone(current_user.curr_timezone), tz_offset: tz_offset})

          messager.send_private_interview(
            @interview,
            user,
            action: :append,
            target: "interview-#{interview_date.strftime('%F')}-#{interview_date.hour}-daily#{tz_offset}", 
            partial: "interviews/timespan_daily",
            locals: presenter.interview_daily_display(@interview, timezone)
                      .merge(timezone: timezone, tz_offset: tz_offset, interview: @interview, action: :create))

          messager.send_private_interview(
            @interview,
            user, 
            action: :append,
            target: "interview-#{interview_date.strftime('%F')}-#{interview_date.hour}-weekly#{tz_offset}", 
            partial: "interviews/timespan_weekly",
            locals: presenter.interview_weekly_display(@interview, timezone)
                      .merge(timezone: timezone, tz_offset: tz_offset, interview: @interview, action: :create))

          messager.send_private_interview(
            @interview,
            user,
            action: :append,
            target: "interviews-#{interview_date.strftime('%F')}-monthly#{tz_offset}", 
            partial: "interviews/timespan_monthly",
            locals: presenter.interview_monthly_display(@interview, timezone)
                      .merge(timezone: timezone, tz_offset: tz_offset, interview: @interview, action: :create))
        end
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @interview.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /interviews/1 or /interviews/1.json
  def update
    respond_to do |format|
      messager = Messager.new(current_user, current_user.curr_timezone)

      if @interview.update(interview_params)
        (@interview.interviewers + [@interview.candidate]).uniq.each do |user|
          presenter = CalendarPresenter.new(Scheduler.new(user))
          timezone = user.curr_timezone
          tz_offset = ActiveSupport::TimeZone[timezone].formatted_offset
          interview_date = @interview.start_time.in_time_zone(timezone)

          # day
          messager.send_private_interview(
            @interview,
            user,
            action: :remove,
            target: "interview-#{@interview.id}-timespan-daily#{tz_offset}")

          messager.send_private_interview(
            @interview, 
            user,
            action: :append,
            target: "interview-#{interview_date.strftime('%F')}-#{interview_date.hour}-daily#{tz_offset}", 
            partial: "interviews/timespan_daily",
            locals: presenter.interview_daily_display(@interview, timezone)
                      .merge(timezone: timezone, tz_offset: tz_offset, interview: @interview, action: :create, is_owner: @interview.owner?(user)))

          # week
          messager.send_private_interview(
            @interview,
            user,
            action: :remove,
            target: "interview-#{@interview.id}-timespan-weekly#{tz_offset}")

          messager.send_private_interview(
            @interview,
            user,
            action: :append,
            target: "interview-#{interview_date.strftime('%F')}-#{interview_date.hour}-weekly#{tz_offset}", 
            partial: "interviews/timespan_weekly",
            locals: presenter.interview_weekly_display(@interview, timezone)
                      .merge(timezone: timezone, tz_offset: tz_offset, interview: @interview, action: :create, is_owner: @interview.owner?(user)))

          # month
          messager.send_private_interview(
            @interview,
            user,
            action: :remove,
            target: "interview-#{@interview.id}-timespan-monthly#{tz_offset}")

          messager.send_private_interview(
            @interview,
            user,
            action: :append,
            target: "interviews-#{interview_date.strftime('%F')}-monthly#{tz_offset}", 
            partial: "interviews/timespan_monthly",
            locals: presenter.interview_monthly_display(@interview, timezone)
                      .merge(timezone: timezone, tz_offset: tz_offset, interview: @interview, action: :create, is_owner: @interview.owner?(user)))
        end
      else
        messager.send_error_flash(error: @interview.errors.first.full_message)
        @interview.reload
      end

      format.html { redirect_to interview_url(@interview), notice: "Interview was successfully updated." }
      format.json { render :show, status: :ok, location: @interview }
      format.turbo_stream { }
    end
  end

  # DELETE /interviews/1 or /interviews/1.json
  def destroy
    @interview.destroy

    respond_to do |format|
      format.html { redirect_to interviews_url, notice: "Interview was successfully destroyed." }
      format.json { head :no_content }

      messager = Messager.new(current_user, current_user.curr_timezone)

      (@interview.interviewers + [@interview.candidate]).uniq.each do |user|
        timezone = user.curr_timezone
        tz_offset = ActiveSupport::TimeZone[timezone].formatted_offset

        messager.send_private_interview(
          @interview, 
          user,
          action: :remove,
          target: "interview-#{@interview.id}-timespan-daily#{tz_offset}")

        messager.send_private_interview(
          @interview,
          user,
          action: :remove,
          target: "interview-#{@interview.id}-timespan-weekly#{tz_offset}")

        messager.send_private_interview(
          @interview,
          user,
          action: :remove,
          target: "interview-#{@interview.id}-timespan-monthly#{tz_offset}")
      end
    end
  end

  SEARCH_LIMIT = 20
  def search
    @interviews = \
      Scheduler.new(current_user)\
        .as_role(:owner, :interviewer, :candidate)
        .by_keyword(params[:keyword])
        .offset(offset = params[:offset].to_i).limit(SEARCH_LIMIT)
    
    @prev_offset = [offset - SEARCH_LIMIT, 0].max
    @next_offset = offset + @interviews.size

    render partial: "interviews/search_result"
  end

  def card
    timezone = current_user.curr_timezone
    tz_offset = ActiveSupport::TimeZone[timezone].formatted_offset

    render layout: false, locals: {timezone: timezone, tz_offset: tz_offset}
  end

  def confirm
    timespan_hour = params[:hour]
    timespan_mday = params[:mday]

    delta_hour = timespan_hour.present? ? timespan_hour.to_i - @interview.start_time.in_time_zone(current_user.curr_timezone).hour : 0
    delta_day = timespan_mday.present? ? timespan_mday.to_i - @interview.start_time.in_time_zone(current_user.curr_timezone).mday : 0

    delta_time = delta_day.day + delta_hour.hour
    @interview.start_time += delta_time
    @interview.end_time += delta_time

    render layout: false
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_interview
      @interview = Interview.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def interview_params
      @interview_params ||= \
        params.require(:interview)
          .permit(:title, :note, :start_time, :end_time, :candidate_id, :applying_id, :round, :head_id, :state, assignments_attributes: [:id, :user_id, :_destroy])    
    end

    def convert_time
      interview_params[:start_time] = interview_params[:start_time].in_time_zone(current_user.curr_timezone).utc if interview_params.has_key?(:start_time)
      interview_params[:end_time] = interview_params[:end_time].in_time_zone(current_user.curr_timezone).utc if interview_params.has_key?(:end_time)
    end
end
