// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "trix"


window.addEventListener("trix-file-accept", function(event) {
  event.preventDefault()
  alert("File attachment not supported!")
})