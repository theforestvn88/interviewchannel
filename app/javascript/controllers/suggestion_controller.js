import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [ "suggestionInput", "suggestionObjectId", "suggestionObject" ]
    static values = { url: String }

    connect() {
        console.log("connect Suggestion Controller");
        this.timeoutId = null
    }

    suggestObjects() {
        if (this.timeoutId) {
            clearTimeout(this.timeoutId)
        }

        this.timeoutId = setTimeout(() => {
            let suggestEndpoint = this.urlValue + `?key=${this.suggestionInputTarget.value}`
            fetch(suggestEndpoint)
                .then((r) => r.text())
                .then((html) => {
                    if (html != "") {
                        this.suggestionObjectTarget.innerHTML = html
                        this.suggestionObjectTarget.classList.remove("hidden")
                    } else {
                        this.suggestionObjectTarget.classList.add("hidden")
                    }
                })
        }, 200) // debounce 200                
    }

    pickSuggestObject(e) {
        this.suggestionInputTarget.value = e.target.getAttribute("data-selected")
        this.suggestionObjectIdTarget.value = e.target.id
        this.suggestionObjectTarget.innerHTML = ""
        this.suggestionObjectTarget.classList.add("hidden")
    }
}
