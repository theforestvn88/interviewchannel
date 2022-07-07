import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [ "icon", "search", "input" ]
    static values = { url: String, resultview: String }

    connect() {
        this.timeoutId = null
        this.resultView = document.getElementById(this.resultviewValue)
    }

    query(e) {
        if (this.timeoutId) {
            clearTimeout(this.timeoutId)
        }

        this.timeoutId = setTimeout(() => {
            let searchEndpoint = this.urlValue + `?key=${this.inputTarget.value}`
            fetch(searchEndpoint)
                .then((r) => r.text())
                .then((html) => {
                  this.resultView.innerHTML = html || ""
                })
        }, 200) // debounce 200                
    }

    expand(e) {
      this.searchTarget.classList.remove("hidden")
      this.iconTarget.classList.add("hidden")
    }

    collapse(e) {
      this.searchTarget.classList.add("hidden")
      this.iconTarget.classList.remove("hidden")

      this.inputTarget.value = ""
      this.query()
    }
}
