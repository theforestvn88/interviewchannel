# frozen_string_literal: true

class Admin::DashboardController < Admin::AdminController
    include SearchParser

    RESOURCES = {
        "User" => {
            :fields => [:id, :name, :email, :created_at, :updated_at, :messages_count, :interviews_count, :banned?],
            :actions => [
                {
                    :name => "ban",
                    :method => :ban,
                    :if => lambda {|user| !user.banned? }
                },
                {
                    :name => "unban",
                    :method => :unban,
                    :if => lambda {|user| user.banned? }
                }
            ]
        },        
        "Tag" => {
            :fields => [:id, :name, :jobs_count],
            :actions => [
                {
                    :name => "delete",
                    :method => :destroy
                }
            ]
        },
        "Message" => {
            :includes => [:owner],
            :fields => [:id, :title, :channel, "owner.email", :created_at, :expired_at, "applyings.count", :views],
            :actions => [
                {
                    :name => "destroy"
                }
            ]
        },
        "Applying" => {
            :includes => [:candidate],
            :fields => [:id, :message_id, "candidate.email", :created_at],
            :actions => [
                {
                    :name => "destroy"
                }
            ]
        },
        "Interview" => {
            :includes => [:owner, :candidate],
            :fields => [:id, "applying.id", "applying.message_id", :round, "owner.email", "candidate.email", :start_time, :end_time],
            :actions => [
                {
                    :name => "destroy"
                }
            ]
        }
    }.freeze

    PAGE_SIZE = 20

    before_action :get_params
    before_action :load, except: [:action]

    def index
    end

    def paging
        render layout: false
    end

    def action
        if @action = params[:a]
            begin
                @record = ActiveSupport::Inflector.constantize(@curr_resource).find_by(id: params[:id])
                @record&.send(@action)
            rescue => e
                puts e
            end
        elsif @search = params[:s]
            @clazz = ActiveSupport::Inflector.constantize(@curr_resource)
            @attributes = @clazz.attribute_names

            @search = @search.to_unsafe_h
            search_clause = @search.map do |field, search_term|
                parts = field.split(".")
                parse(parts.last, search_term) if search_term.present? && (parts.size > 1 || @attributes.include?(parts.last))
            end.reject { |t| t.blank? }.join(" AND ")
            
            joins = @search.map do |field, search_term|
                if search_term.present? && (_parts = field.split(".")).size > 1
                    _parts.first.to_sym
                end
            end.compact

            methods = @search.filter do |field, search_term|
                search_term.present? && field.split(".").size == 1
            end

            @result = joins.empty? ? @clazz : @clazz.joins(*joins)
            @result = @result.where(search_clause)
            @total_records= @result.count
            @records = @result.offset(PAGE_SIZE * @curr_page).limit(PAGE_SIZE)
            methods.each do |m, v|
                @records = @records.select do |r|
                    if r.respond_to?(m)
                        r.send(m).to_s == v
                    else
                        true
                    end
                end
            end

            set_pager
        end
    end

    private def get_params
        @resources = RESOURCES.keys
        @curr_resource = params[:r] || @resources.first
        @curr_includes = RESOURCES.dig(@curr_resource, :includes)
        @curr_fields = RESOURCES.dig(@curr_resource, :fields)
        @curr_actions = RESOURCES.dig(@curr_resource, :actions)
        @curr_page = params[:p].to_i
    end

    private def load
        @records = ActiveSupport::Inflector.constantize(@curr_resource)
        @records = @records.includes(*@curr_includes) unless @curr_includes.blank?
        @total_records = @records.count
        @records = @records.offset(PAGE_SIZE * @curr_page).limit(PAGE_SIZE)
        set_pager
    end

    private def set_pager
        @total_pages = (@total_records / PAGE_SIZE).ceil
    end
end
