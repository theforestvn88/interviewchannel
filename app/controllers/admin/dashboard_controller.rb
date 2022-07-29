# frozen_string_literal: true

class Admin::DashboardController < Admin::AdminController
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
        @record = ActiveSupport::Inflector.constantize(@curr_resource).find_by(id: params[:id])
        if @action = params[:a]
            begin
                @record&.send(@action)
            rescue => e
                puts e
            end
        end
    end

    private def get_params
        @resources = RESOURCES.keys
        @curr_resource = params[:r] || @resources.first
        @curr_fields = RESOURCES.dig(@curr_resource, :fields)
        @curr_actions = RESOURCES.dig(@curr_resource, :actions)
        @page = params[:p].to_i
        @search = params[:s]
    end

    private def load
        @records = ActiveSupport::Inflector.constantize(@curr_resource).offset(PAGE_SIZE * @page).limit(PAGE_SIZE)
    end
end
