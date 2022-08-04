# ADMIN
User.find_or_create_by(
    id: 1, 
    uid: Rails.application.credentials.admin[:uid],#"54012293" 
    name: Rails.application.credentials.admin[:name],#"theforestvn88", 
    email: Rails.application.credentials.admin[:email],#"velainuirung@gmail.com", 
    image: Rails.application.credentials.admin[:image],#"https://avatars.githubusercontent.com/u/54012293?v=4", 
    github: Rails.application.credentials.admin[:github],#"https://github.com/theforestvn88"
)


# Settings
Setting.create(
    key: "social",
    value: ["blog", "hackerrank", "leetcode", "dev.to", "stackoverflow", "codeforces", "medium", "linkedin", "twitter"]
)
