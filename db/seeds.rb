# ADMIN
User.find_or_create_by(
    id: 1, 
    uid: Rails.application.credentials.admin[:uid],
    name: Rails.application.credentials.admin[:name],
    email: Rails.application.credentials.admin[:email],
    image: Rails.application.credentials.admin[:image],
)


# Settings
Setting.destroy_all

Setting.create(
    key: "social",
    value: ["github", "linkedin", "twitter", "blog", "hackerrank", "leetcode", "dev.to", "stackoverflow", "codeforces", "medium"]
)

Setting.create(
    key: "social_auth",
    value: {
        providers: ["github", "google", "twitter", "linkedin"]
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



# Tags
Tag.destroy_all
Tag.insert_all!([
    {name: "Rails", category: "frameworks", pos: 1},
    {name: "Sinatra", category: "frameworks", pos: 2},
    {name: "Hanami", category: "frameworks", pos: 2},
    {name: "Ruby", category: "languages", pos: 1},
    {name: "Django", category: "frameworks", pos: 1},
    {name: "Flask", category: "frameworks", pos: 2},
    {name: "Python", category: "languages", pos: 1},
    {name: "Javascript", category: "languages", pos: 1},
    {name: "TypeScript", category: "languages", pos: 1},
    {name: "NodeJs", category: "frameworks", pos: 1},
    {name: "Express", category: "frameworks", pos: 2},
    {name: "React", category: "frameworks", pos: 1},
    {name: "Angular", category: "frameworks", pos: 1},
    {name: "Vue", category: "frameworks", pos: 1},
    {name: "Ember", category: "frameworks", pos: 2},
    {name: "Svelte", category: "frameworks", pos: 3},
    {name: "Gatsby", category: "frameworks", pos: 3},
    {name: "Next.js", category: "frameworks", pos: 3},
    {name: "Html/Css", category: "others", pos: 2},
    {name: "Ionic", category: "frameworks", pos: 4},
    {name: "React-Native", category: "frameworks", pos: 3},
    {name: "Java", category: "languages", pos: 1},
    {name: "Kotlin", category: "languages", pos: 1},
    {name: "Android", category: "others", pos: 1},
    {name: "Spring", category: "frameworks", pos: 1},
    {name: "Struts", category: "frameworks", pos: 4},
    {name: "Stripes", category: "frameworks", pos: 4},
    {name: "Spark", category: "frameworks", pos: 4},
    {name: "Hibernate", category: "frameworks", pos: 3},
    {name: "Dart", category: "languages", pos: 2},
    {name: "Flutter", category: "frameworks", pos: 2},
    {name: "Xamarin", category: "frameworks", pos: 2},
    {name: "PhoneGap", category: "frameworks", pos: 5},
    {name: "Corona", category: "frameworks", pos: 5},
    {name: "Swift", category: "languages", pos: 1},
    {name: "Objective-C", category: "languages", pos: 4},
    {name: "iOS", category: "others", pos: 1},
    {name: "Rust", category: "languages", pos: 2},
    {name: "Go", category: "languages", pos: 1},
    {name: "Elixir", category: "languages", pos: 2},
    {name: "C", category: "languages", pos: 2},
    {name: "C++", category: "languages", pos: 2},
    {name: "C#", category: "languages", pos: 1},
    {name: "Unity", category: "frameworks", pos: 1},
    {name: ".NET", category: "frameworks", pos: 1},
    {name: "PHP", category: "languages", pos: 1},
    {name: "CakePHP", category: "frameworks", pos: 4},
    {name: "CodeIgniter", category: "frameworks", pos: 4},
    {name: "Laravel", category: "frameworks", pos: 1},
    {name: "Symfony", category: "frameworks", pos: 4},
    {name: "Yii", category: "frameworks", pos: 4},
    {name: "Zend", category: "frameworks", pos: 4},
    {name: "Drupal", category: "frameworks", pos: 3},
    {name: "Meteor", category: "frameworks", pos: 4},
    {name: "Joomla", category: "frameworks", pos: 5},
    {name: "Perl", category: "languages", pos: 5},
    {name: "Postgresql", category: "others", pos: 2},
    {name: "MySql", category: "others", pos: 2},
    {name: "MongoDB", category: "others", pos: 3},
    {name: "Oracle", category: "others", pos: 3},
    {name: "Microsoft SQL Server", category: "others", pos: 4},
    {name: "SQLite", category: "others", pos: 4},
    {name: "Redis", category: "others", pos: 3},
    {name: "MariaDB", category: "others", pos: 2},
    {name: "Firebase", category: "others", pos: 3},
    {name: "Elasticsearch", category: "others", pos: 3},
    {name: "SQL", category: "others", pos: 3},
    {name: "AWS", category: "others", pos: 2},
    {name: "R", category: "languages", pos: 4},
    {name: "Carbon", category: "languages", pos: 3},
    {name: "Delphi", category: "languages", pos: 3},
    {name: "Haskell", category: "languages", pos: 3},
    {name: "Julia", category: "languages", pos: 4},
    {name: "Lua", category: "languages", pos: 4},
    {name: "Smalltalk", category: "languages", pos: 3},
    {name: "Scala", category: "languages", pos: 2},
    {name: "Erlang", category: "languages", pos: 2},
    {name: "Lisp", category: "languages", pos: 4},
    {name: "COBOL", category: "languages", pos: 5},
    {name: "Fortran", category: "languages", pos: 5},
    {name: "Assembly", category: "languages", pos: 3},
    {name: "Phoenix", category: "frameworks", pos: 2},
    {name: "Groovy", category: "languages", pos: 4},
    {name: "Grails", category: "frameworks", pos: 4},
    {name: "Kafka", category: "others", pos: 2},
    {name: "Bootstrap", category: "others", pos: 3},
    {name: "Tailwindcss", category: "others", pos: 3},
    {name: "PyTorch", category: "others", pos: 1},
    {name: "TensorFlow", category: "others", pos: 1},
    {name: "Machine Learning", category: "others", pos: 1},
    {name: "Salesforce", category: "others", pos: 2},
    {name: "Blockchain", category: "others", pos: 1},
    {name: "Tester", category: "roles", pos: 1},
    {name: "Computer Programmer", category: "roles", pos: 2},
    {name: "Web Developer", category: "roles", pos: 1},
    {name: "Computer systems engineer", category: "roles", pos: 3},
    {name: "Analyst", category: "roles", pos: 2},
    {name: "Data Scientist", category: "roles", pos: 1},
    {name: "Database Administrator", category: "roles", pos: 3},
    {name: "Database Architect", category: "roles", pos: 3},
    {name: "Database Engineer", category: "roles", pos: 3},
    {name: "QA Engineer", category: "roles", pos: 1},
    {name: "Business Analyst", category: "roles", pos: 1},
    {name: "Network Administrator", category: "roles", pos: 2},
    {name: "Security Analyst", category: "roles", pos: 4},
    {name: "Mobile Developer", category: "roles", pos: 1},
    {name: "Android Developer", category: "roles", pos: 2},
    {name: "iOS Developer", category: "roles", pos: 2},
    {name: "Software Architect", category: "roles", pos: 1},
    {name: "Full Stack Developer", category: "roles", pos: 1},
    {name: "Front End Developer", category: "roles", pos: 1},
    {name: "Back End Developer", category: "roles", pos: 1},
    {name: "Senior Developer", category: "roles", pos: 1},
    {name: "Junior Developer", category: "roles", pos: 1},
    {name: "Entry Developer", category: "roles", pos: 1},
    {name: "Data Engineer", category: "roles", pos: 2},
    {name: "SQL Developer", category: "roles", pos: 4},
    {name: "Game Developer", category: "roles", pos: 1},
    {name: "Embedded Software Engineer", category: "roles", pos: 3},
    {name: "Director of Engineering", category: "roles", pos: 5},
])