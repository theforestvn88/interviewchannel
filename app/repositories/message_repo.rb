# frozen_string_literal: true

class MessageRepo
    class << self
        def query(by_time:, by_tags: nil, by_user: nil)
            q = Message.by_updated_time(by_time)
            q = q.by_tags(by_tags) unless by_tags.blank? or by_tags == ["#all"]
            q = q.by_owner(by_user.id) if by_user
            q
        end

        def count(by_time:, by_tag: nil, by_user: nil)
            Rails.cache.fetch("count:#{by_tag&.downcase}#{by_user&.id}", expires_in: 1.day, raw: true) {
                MessageRepo.fetch(by_time: by_time, by_tags: Array(by_tag), by_user: by_user).count
            }
        end

        def fetch(by_time:, by_tags: nil, by_user: nil)
            Rails.cache.fetch("ids:#{by_tags&.map(&:downcase)&.join("#")}#{by_user&.id}", expires_in: 1.day, raw: true) {
                MessageRepo.query(by_time: by_time, by_tags: Array(by_tags), by_user: by_user).select(:id)
            }
        end

        def increase_counter_by_tags(tags)
            Rails.cache.redis.pipelined  do |pipeline|
                tags.each do |tag|
                    pipeline.incr "count:#{tag&.downcase} "
                end
            end
        end

        def decrease_counter_by_tags(tags)
            Rails.cache.redis.pipelined  do |pipeline|
                tags.each do |tag|
                    pipeline.decr "count:#{tag&.downcase} "
                end
            end
        end
    end
end
