# frozen_string_literal: true

class Messager
    module Query

        PAGE = 20

        def fetch(by_time:, by_tags: nil, by_user: nil, sort_by: nil, order: nil)
            _tags = by_tags&.filter {|t| t.to_s != "#all"}
            MessageRepo.fetch(by_tags: _tags, by_time: by_time, by_user: by_user, sort_by: sort_by)
        end

        def recently(tag, offset_time: Time.now.utc, sort_by: [], limit: PAGE)
            ids = fetch(by_tags: Array(tag), by_time: @one_month_ago_utc..offset_time, sort_by: sort_by.map {|s| [s, :desc]}.push([:updated_at, :desc]))
                    .first(limit)
            cached_messages = Message.where(id: ids).includes(:owner).map {|msg| [msg.id, msg]}.to_h
            messages = ids.map { |id| cached_messages[id] }
            messages
        end

        def own_by_me(offset_time: Time.now.utc, limit: PAGE)
            return [] if @user.nil?

            MessageRepo.query(by_user: @user, by_time: @one_month_ago_utc..offset_time, limit: limit)
        end

        def inbox_messages(user, filter: {}, offset_time: Time.now.utc, limit: PAGE)
            return [] if user.nil?

            PrivateMessageRepo.query(
              by_user: user,
              by_user_id: filter.dig(:user, :id).to_i, 
              by_job: filter[:job].to_i, 
              by_time: @one_month_ago_utc..offset_time, 
              limit: limit
            )
        end
    end
end
