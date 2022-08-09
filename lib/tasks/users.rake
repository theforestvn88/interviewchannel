# frozen_string_literal: true

require "faker"

desc "faking users"
task "users:fake" => :environment do
    clear_fake_users
    fake_users
end

def clear_fake_users
    puts "CLEAR FAKER USERs ..."
    User.where(id: 1000..10000).destroy_all
end

def fake_users
    puts "FAKING USERs ..."
    _fake_users = (1000..10000).each do |id|
        User.create(
            id: id, 
            uid: Faker::Internet.uuid,
            name: Faker::Name.name,
            email: Faker::Internet.unique.email,
            image: "",
            github: "",
        )
    end
end


require 'benchmark/ips'
desc "benchmark users search"
task "users:benchmark" => [:environment, 'users:fake'] do
    Benchmark.ips do |x|
        current_user = User.first
        x.report("suggest") do
            current_user.contacts.includes(:friend).suggest("abc").first(6).map(&:friend)
            User.suggest("abc".strip).first(6)
        end
    end

    clear_fake_users
end


#
# NOT INDEX:
#
# Warming up --------------------------------------
#              suggest     3.000  i/100ms
# Calculating -------------------------------------
#              suggest     31.773  (± 0.0%) i/s -    159.000  in   5.004678s
#
#
#
# TRIGRAM GIN INDEX
# Warming up --------------------------------------
#              suggest     3.000  i/100ms
# Calculating -------------------------------------
#              suggest     37.075  (± 0.0%) i/s -    186.000  in   5.017306s
#
#
#
