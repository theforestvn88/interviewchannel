class InterviewsController < ApplicationController
  before_action :ensure_user_signed_in
  before_action :set_interview, only: %i[ show room edit update destroy card confirm assign ]
  before_action :allow_only_owner, only: %i[ edit update destroy assign ]
  before_action :convert_time, only: %i[ create update ]

  # GET /interviews or /interviews.json
  def index
    @interviews = Interview.all
  end

  # GET /interviews/1 or /interviews/1.json
  def show
    @showable = @interview && @interview.involve?(current_user)
    render layout: false
  end

  def room
    unless @interview && @interview.involve?(current_user) && @interview.started?
      redirect_to root_path
    end

    msg = "#{current_user.name} joined interview room##{@interview.id}"
    Note.create!(content: msg, cc: "cc: @all", user_id: @interview.owner_id, interview_id: @interview.id)

    (@interview.interviewers + [@interview.candidate]).uniq.each do |user|
      @messager.send_flash_to_user(user, 
        content: msg,
        link_to: {
          path: interview_path(@interview), 
          data: {turbo_frame: "home-content"}
        }
      )
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
    RateLimiter.new(
      current_user, 
      :created_interviews, 
      SettingRepo.fetch("rate_limiter.interview_limit_per_day"), 
      :day_exceeded, 
      expires_at: today_in_curr_timezone.next_day.beginning_of_day.utc
    ).check!

    @interview = Interview.new(interview_params)
    @interview.owner = current_user

    respond_to do |format|
      if @interview.save
        if applying = @interview.applying
          @messager.create_and_send_private_reply(
            applying: applying, 
            sender_id: current_user.id, 
            type: Reply::INTERVIEW_TYPE,
            cc: all_assignment_user_ids,
            partial: "replies/create_interview_reply", 
            locals: {interview: @interview, owner: current_user, timezone: current_user.curr_timezone},
            flash: "I scheduled a new interview for you. Good Luck!",
            link_to: {
              path: applying_path(applying),
              data: {turbo_frame: "home-content"}
            }
          )
        end

        (@interview.interviewers + [@interview.candidate]).uniq.each do |user|
          presenter = CalendarPresenter.new(Scheduler.new(user))
          timezone = user.curr_timezone
          tz_offset = ActiveSupport::TimeZone[timezone].formatted_offset
          interview_date = @interview.start_time.in_time_zone(timezone)

          @messager.send_private_interview(
            @interview,
            user,
            action: :replace,
            target: "#{interview_date.strftime('%d-%b')}-#{tz_offset}", 
            partial: "interviews/mini_day",
            locals: {interview_date: interview_date, today: Time.now.in_time_zone(current_user.curr_timezone), tz_offset: tz_offset})

          @messager.send_private_interview(
            @interview,
            user,
            action: :append,
            target: "interview-#{interview_date.strftime('%F')}-#{interview_date.hour}-daily#{tz_offset}", 
            partial: "interviews/timespan_daily",
            locals: presenter.interview_daily_display(@interview, timezone)
                      .merge(timezone: timezone, tz_offset: tz_offset, interview: @interview, action: :create))

          @messager.send_private_interview(
            @interview,
            user, 
            action: :append,
            target: "interview-#{interview_date.strftime('%F')}-#{interview_date.hour}-weekly#{tz_offset}", 
            partial: "interviews/timespan_weekly",
            locals: presenter.interview_weekly_display(@interview, timezone)
                      .merge(timezone: timezone, tz_offset: tz_offset, interview: @interview, action: :create))

          @messager.send_private_interview(
            @interview,
            user,
            action: :append,
            target: "interviews-#{interview_date.strftime('%F')}-monthly#{tz_offset}", 
            partial: "interviews/timespan_monthly",
            locals: presenter.interview_monthly_display(@interview, timezone)
                      .merge(timezone: timezone, tz_offset: tz_offset, interview: @interview, action: :create))
        end

        Contact.hit(current_user.id, @interview.candidate_id)
        interview_params.dig(:interview, :assignments_attributes)&.map {|a| a["user_id"]}&.each do |user_id|
          Contact.hit(current_user.id, user_id)
        end
      else
        # @messager.send_error_flash(error: @interview.errors.first.full_message)
      end

      format.turbo_stream { }
    end
  end

  # PATCH/PUT /interviews/1 or /interviews/1.json
  def update
    respond_to do |format|
      if @interview.update(interview_params)
        if applying = @interview.applying
          if @interview.canceled?
            @messager.create_and_send_private_reply(
              applying: applying, 
              sender_id: current_user.id, 
              type: Reply::INTERVIEW_TYPE,
              cc: @interview.interviewers.pluck(:id),
              partial: "replies/cancel_interview_reply", 
              locals: { interview: @interview, owner: current_user, timezone: current_user.curr_timezone },
              flash: "The interview##{@interview.id} is canceled!",
              link_to: {
                path: applying_path(applying),
                data: {turbo_frame: "home-content"}
              }
            )            
          else
            if dropped_assignments.present?
              @messager.create_and_send_private_reply(
                applying: applying, 
                sender_id: current_user.id, 
                type: Reply::INTERVIEW_TYPE,
                cc: all_assignment_user_ids,
                partial: "replies/remove_interviewers_reply", 
                locals: {
                  interview: @interview, 
                  timezone: current_user.curr_timezone, 
                  interviewers: dropped_assignments,
                  owner: current_user
                },
                flash: "The interview##{@interview.id} is updated!",
                link_to: {
                  path: applying_path(applying),
                  data: {turbo_frame: "home-content"}
                }
              )
            end

            if new_assignments.present?
              @messager.create_and_send_private_reply(
                applying: applying, 
                sender_id: current_user.id, 
                type: Reply::ASSIGNMENT_TYPE,
                cc: all_assignment_user_ids,
                partial: "replies/assign_interviewers_reply", 
                locals: {
                  interview: @interview, 
                  timezone: current_user.curr_timezone, 
                  interviewers: new_assignments,
                  owner: current_user
                },
                flash: "The interview##{@interview.id} is updated!",
                link_to: {
                  path: applying_path(applying),
                  data: {turbo_frame: "home-content"}
                }
              )
            end

            if @change_time
              @messager.create_and_send_private_reply(
                applying: applying, 
                sender_id: current_user.id,
                type: Reply::INTERVIEW_TYPE, 
                cc: all_assignment_user_ids,
                partial: "replies/update_time_interview_reply", 
                locals: { interview: @interview, owner: current_user, timezone: "UTC" },
                flash: "The interview##{@interview.id} is updated!",
                link_to: {
                  path: applying_path(applying),
                  data: {turbo_frame: "home-content"}
                }
              )               
            end
          end
        end

        (@interview.interviewers + [@interview.candidate]).uniq.each do |user|
          presenter = CalendarPresenter.new(Scheduler.new(user))
          timezone = user.curr_timezone
          tz_offset = ActiveSupport::TimeZone[timezone].formatted_offset
          interview_date = @interview.start_time.in_time_zone(timezone)

          # day
          @messager.send_private_interview(
            @interview,
            user,
            action: :remove,
            target: "interview-#{@interview.id}-timespan-daily#{tz_offset}")

          @messager.send_private_interview(
            @interview, 
            user,
            action: :append,
            target: "interview-#{interview_date.strftime('%F')}-#{interview_date.hour}-daily#{tz_offset}", 
            partial: "interviews/timespan_daily",
            locals: presenter.interview_daily_display(@interview, timezone)
                      .merge(timezone: timezone, tz_offset: tz_offset, interview: @interview, action: :create, is_owner: @interview.owner?(user)))

          # week
          @messager.send_private_interview(
            @interview,
            user,
            action: :remove,
            target: "interview-#{@interview.id}-timespan-weekly#{tz_offset}")

          @messager.send_private_interview(
            @interview,
            user,
            action: :append,
            target: "interview-#{interview_date.strftime('%F')}-#{interview_date.hour}-weekly#{tz_offset}", 
            partial: "interviews/timespan_weekly",
            locals: presenter.interview_weekly_display(@interview, timezone)
                      .merge(timezone: timezone, tz_offset: tz_offset, interview: @interview, action: :create, is_owner: @interview.owner?(user)))

          # month
          @messager.send_private_interview(
            @interview,
            user,
            action: :remove,
            target: "interview-#{@interview.id}-timespan-monthly#{tz_offset}")

          @messager.send_private_interview(
            @interview,
            user,
            action: :append,
            target: "interviews-#{interview_date.strftime('%F')}-monthly#{tz_offset}", 
            partial: "interviews/timespan_monthly",
            locals: presenter.interview_monthly_display(@interview, timezone)
                      .merge(timezone: timezone, tz_offset: tz_offset, interview: @interview, action: :create, is_owner: @interview.owner?(user)))
        end

        new_assignments.each do |user_id|
          Contact.hit(current_user.id, user_id)
        end
      else
        # @messager.send_error_flash(error: @interview.errors.first.full_message)
        # @interview.reload
      end

      format.turbo_stream { }
    end
  end

  def assign
    render layout: false
  end

  # DELETE /interviews/1 or /interviews/1.json
  def destroy
    @interview.destroy

    respond_to do |format|
      format.html { redirect_to interviews_url, notice: "Interview was successfully destroyed." }
      format.json { head :no_content }

      (@interview.interviewers + [@interview.candidate]).uniq.each do |user|
        timezone = user.curr_timezone
        tz_offset = ActiveSupport::TimeZone[timezone].formatted_offset

        @messager.send_private_interview(
          @interview, 
          user,
          action: :remove,
          target: "interview-#{@interview.id}-timespan-daily#{tz_offset}")

        @messager.send_private_interview(
          @interview,
          user,
          action: :remove,
          target: "interview-#{@interview.id}-timespan-weekly#{tz_offset}")

        @messager.send_private_interview(
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
        .offset(offset = params[:offset].to_i)
        .limit(SEARCH_LIMIT)
    
    @prev_offset = [offset - SEARCH_LIMIT, 0].max
    @next_offset = offset + @interviews.size

    render partial: "interviews/search_result"
  end

  def card
    render layout: false, locals: {timezone: "UTC"}
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

    def allow_only_owner
      @interview.owner?(current_user)
    end

    # Only allow a list of trusted parameters through.
    def interview_params
      @interview_params ||= \
        params.require(:interview)
          .permit(:title, :note, :start_time, :end_time, :candidate_id, :applying_id, :round, :head_id, :state, assignments_attributes: [:id, :user_id, :_destroy])    
    end

    def new_assignments
      assignments = @interview_params[:assignments_attributes]&.select do |id, assignment|
        assignment[:id].nil? && assignment[:_destroy].nil? && assignment[:user_id].present?
      end&.to_hash
      
      assignments.present? ? User.where(id: assignments.values.map{|a| a["user_id"]}) : []
    end

    def dropped_assignments
      assignments = @interview_params[:assignments_attributes]&.select do |id, assignment|
        assignment[:id].present? && assignment[:_destroy].present?
      end&.to_hash

      assignments.present? ? User.where(id: assignments.values.map{|a| a["user_id"]}) : []
    end

    def all_assignment_user_ids
      return [] if @interview_params[:assignments_attributes].nil?

      @interview_params[:assignments_attributes].select do |id, assignment|
        assignment[:user_id].present?
      end.to_hash.values.map{|a| a["user_id"]}
    end

    def convert_time
      interview_params[:start_time] = interview_params[:start_time].in_time_zone(current_user.curr_timezone).utc if interview_params.has_key?(:start_time)
      interview_params[:end_time] = interview_params[:end_time].in_time_zone(current_user.curr_timezone).utc if interview_params.has_key?(:end_time)
      @change_time = @interview.present? && (
                        (interview_params[:start_time].present? && interview_params[:start_time] != @interview.start_time) ||
                        (interview_params[:end_time].present? && interview_params[:end_time] != @interview.end_time)
                      )
    end
end
