import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [ "confirmDialog", "suggestionUserInput", "suggestionUserId", "suggestionUser" ]
    static values = { suggestUserUrl: String }

    connect() {
        this.timeZone = Intl.DateTimeFormat().resolvedOptions().timeZone
        this.timeoutId = null
    }

    showConfirmDialog() {
        if (this.hasConfirmDialogTarget) {
            this.confirmDialogTarget.classList.remove("hidden")
        }
    }

    hideConfirmDialog() {
        if (this.hasConfirmDialogTarget) {
            this.confirmDialogTarget.classList.add("hidden")
        }
    }

    suggestUser() {
        if (this.timeoutId) {
            clearTimeout(this.timeoutId)
        }

        this.timeoutId = setTimeout(() => {
            let suggestEndpoint = this.suggestUserUrlValue + `?key=${this.suggestionUserInputTarget.value}`
            fetch(suggestEndpoint)
                .then((r) => r.text())
                .then((html) => {
                    if (html != "") {
                        this.suggestionUserTarget.innerHTML = html
                        this.suggestionUserTarget.classList.remove("hidden")
                    } else {
                        this.suggestionUserTarget.classList.add("hidden")
                    }
                })
        }, 200) // debounce 200                
    }

    pickSuggestUser(e) {
        this.suggestionUserInputTarget.value = e.target.getAttribute("data-selected")
        this.suggestionUserIdTarget.value = e.target.id
        this.suggestionUserTarget.innerHTML = ""
        this.suggestionUserTarget.classList.add("hidden")
    }
}
