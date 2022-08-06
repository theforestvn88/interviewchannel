# ADMIN
User.find_or_create_by(
    id: 1, 
    uid: Rails.application.credentials.admin[:uid],
    name: Rails.application.credentials.admin[:name],
    email: Rails.application.credentials.admin[:email],
    image: Rails.application.credentials.admin[:image],
    github: Rails.application.credentials.admin[:github],
)


# Settings
Setting.create(
    key: "social",
    value: ["blog", "hackerrank", "leetcode", "dev.to", "stackoverflow", "codeforces", "medium", "linkedin", "twitter"]
)

Setting.create(
    key: "social_auth",
    value: {
        providers: ["github", "google", "twitter"]
    }
)

Setting.create(
    key: "rate_limiter",
    value: {
        interview_limit_per_day: 100,
        message_limit_per_day: 10,
        reply_limit_per_day: 1000
    }
)