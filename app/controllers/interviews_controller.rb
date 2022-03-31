class InterviewsController < ApplicationController
  before_action :set_interview, only: %i[ show room edit update destroy card ]

  # GET /interviews or /interviews.json
  def index
    @interviews = Interview.all
  end

  # GET /interviews/1 or /interviews/1.json
  def show
  end

  def room
  end

  # GET /interviews/new
  def new
    @interview = Interview.new
  end

  # GET /interviews/1/edit
  def edit
    render layout: false
  end

  # POST /interviews or /interviews.json
  def create
    @interview = Interview.new(interview_params)
    @interview.start_time = interview_params[:start_time].in_time_zone(current_user.curr_timezone).utc
    @interview.end_time = interview_params[:end_time].in_time_zone(current_user.curr_timezone).utc

    respond_to do |format|
      if @interview.save
        format.html { redirect_to interview_url(@interview), notice: "Interview was successfully created." }
        format.json { render :show, status: :created, location: @interview }

        [@interview.interviewer, @interview.candidate].each do |participant|
          timezone = participant.curr_timezone
          tz_offset = ActiveSupport::TimeZone[timezone].formatted_offset

          Turbo::StreamsChannel.broadcast_replace_to(
            :interviews,
            target: "interview-#{@interview.start_time.strftime('%F')}-#{@interview.start_time.in_time_zone(timezone).hour}-daily#{tz_offset}", 
            partial: "interviews/timespan_daily",
            locals: CalendarPresenter.interview_daily_display(@interview, timezone)
                      .merge(timezone: timezone, tz_offset: tz_offset, interview: @interview, action: :create)
          )

          Turbo::StreamsChannel.broadcast_replace_to(
            :interviews,
            target: "interview-#{@interview.start_time.strftime('%F')}-#{@interview.start_time.in_time_zone(timezone).hour}-weekly#{tz_offset}", 
            partial: "interviews/timespan_weekly",
            locals: CalendarPresenter.interview_weekly_display(@interview, timezone)
                      .merge(timezone: timezone, tz_offset: tz_offset, interview: @interview, action: :create)
          )

          Turbo::StreamsChannel.broadcast_append_to(
            :interviews,
            target: "interviews-#{@interview.start_time.strftime('%F')}-monthly#{tz_offset}", 
            partial: "interviews/timespan_monthly",
            locals: {timezone: timezone, tz_offset: tz_offset, interview: @interview, action: :create}
          )
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
      if @interview.update(interview_params)
        format.html { redirect_to interview_url(@interview), notice: "Interview was successfully updated." }
        format.json { render :show, status: :ok, location: @interview }

        [@interview.interviewer, @interview.candidate].each do |participant|
          timezone = participant.curr_timezone
          tz_offset = ActiveSupport::TimeZone[timezone].formatted_offset

          Turbo::StreamsChannel.broadcast_replace_to(
            @interview,
            target: "interview-#{@interview.id}-timespan-daily#{tz_offset}", 
            partial: "interviews/timespan_daily",
            locals: CalendarPresenter.interview_daily_display(@interview, timezone)
                      .merge(timezone: timezone, tz_offset: tz_offset, interview: @interview, action: :update)
          )

          Turbo::StreamsChannel.broadcast_replace_to(
            @interview,
            target: "interview-#{@interview.id}-timespan-weekly#{tz_offset}", 
            partial: "interviews/timespan_weekly",
            locals: CalendarPresenter.interview_weekly_display(@interview, timezone)
                      .merge(timezone: timezone, tz_offset: tz_offset, interview: @interview, action: :update)
          )

          Turbo::StreamsChannel.broadcast_replace_to(
            @interview,
            target: "interview-#{@interview.id}-timespan-monthly#{tz_offset}", 
            partial: "interviews/timespan_monthly",
            locals: {timezone: timezone, tz_offset: tz_offset, interview: @interview, action: :update}
          )
        end
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @interview.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /interviews/1 or /interviews/1.json
  def destroy
    @interview.destroy

    respond_to do |format|
      format.html { redirect_to interviews_url, notice: "Interview was successfully destroyed." }
      format.json { head :no_content }

      [@interview.interviewer, @interview.candidate].each do |participant|
        timezone = participant.curr_timezone
        tz_offset = ActiveSupport::TimeZone[timezone].formatted_offset

        Turbo::StreamsChannel.broadcast_remove_to(
          @interview,
          target: "interview-#{@interview.id}-timespan-daily#{tz_offset}"
        )

        Turbo::StreamsChannel.broadcast_remove_to(
          @interview,
          target: "interview-#{@interview.id}-timespan-weekly#{tz_offset}"
        )

        Turbo::StreamsChannel.broadcast_remove_to(
          @interview,
          target: "interview-#{@interview.id}-timespan-monthly#{tz_offset}"
        )
      end
    end
  end

  SEARCH_LIMIT = 20
  def search
    @interviews = \
      Scheduler.new(current_user)\
        .as_role(:interviewer, :candidate)
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_interview
      @interview = Interview.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def interview_params
      params.require(:interview).permit(:note, :start_time, :end_time, :code, :result)
    end
end
