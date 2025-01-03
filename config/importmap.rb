# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"

pin "highlight.js", to: "https://ga.jspm.io/npm:highlight.js@11.4.0/es/index.js", preload: true
pin_all_from "app/javascript/formatter", under: "formatter"
pin_all_from "app/javascript/interview", under: "interview"

pin "trix", to: "https://cdn.skypack.dev/trix"
