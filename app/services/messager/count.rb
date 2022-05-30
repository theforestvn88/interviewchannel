# frozen_string_literal: true

class Messager
    module Count
        def count_by_tag(tag)
            MessageRepo.count(by_tag: tag, by_time: @one_month_ago_utc..., expires_in: 1.day)
        end

        def count_by_user(user)
            MessageRepo.count(by_user: user, by_time: @one_month_ago_utc..., expires_in: 1.day)
        end

        def count_all
            count_by_tag "#all"
        end

        def increase_then_broadcast_counter(message)
            message.tags.each { |tag| count_by_tag(tag) } # fetch tag-counter before increase, for sure
            broadcast_tags message.tags.zip(MessageRepo.increase_counter_by_tags(message.tags))
        end

        def decrease_then_broadcast_counter(message)
            broadcast_tags message.tags.zip(MessageRepo.decrease_counter_by_tags(message.tags))
        end

        def broadcast_tags(tags_with_count)
            tags_with_count.each do |(tag, count)|
                Turbo::StreamsChannel.broadcast_replace_to(
                    :tags,
                    target: "tag_#{tag.gsub("#", "")}", 
                    partial: "messages/tag",
                    locals: {tag: tag, count: count}
                )
            end

            self
        end
    end
end
