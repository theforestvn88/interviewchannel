# frozen_string_literal: true

require "faker"

desc "faking messages"
task "messages:fake" => :environment do
    clear_fake_messages
    fake_messages
end

def clear_fake_messages
    puts "CLEAR FAKER Messages ..."
    Message.where(id: 1000..10000).destroy_all
end

def fake_messages
    puts "FAKING Messages ..."
    (1000..10000).each do |id|
        Message.create(
            id: id, 
            title: "The Job Message #{id}",
            channel: Faker::Lorem.sentence(word_count: 3),
            content: Faker::Lorem.paragraph,
            user_id: id,
            expired_at: 1.day.from_now
        )
    end
end


require 'benchmark/ips'
desc "benchmark messages search by tags"
task "messages:benchmark" => [:environment, 'messages:fake'] do
    Benchmark.ips do |x|
        x.report("suggest") do
            Message.by_tags(["#Rails", "#Ruby"]).first(20)
        end
    end

    clear_fake_messages
end
