import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [ "confirmDialog", "suggestionUserInput", "suggestionUserId", "suggestionUser" ]
    static values = { suggestUserUrl: String }

    connect() {
        this.timeZone = Intl.DateTimeFormat().resolvedOptions().timeZone;
    }

    showConfirmDialog() {
        if (this.hasConfirmDialogTarget) {
            this.confirmDialogTarget.classList.remove("hidden");
        }
    }

    hideConfirmDialog() {
        if (this.hasConfirmDialogTarget) {
            this.confirmDialogTarget.classList.add("hidden");
        }
    }

    suggestUser() {
        let suggestEndpoint = this.suggestUserUrlValue + `?key=${this.suggestionUserInputTarget.value}`
        fetch(suggestEndpoint)
            .then((r) => r.text())
            .then((html) => {
                this.suggestionUserTarget.innerHTML = html
                this.suggestionUserTarget.classList.remove("hidden")
            })
    }

    pickSuggestUser(e) {
        this.suggestionUserInputTarget.value = e.target.textContent
        this.suggestionUserIdTarget.value = e.target.id
        this.suggestionUserTarget.innerHTML = ""
        this.suggestionUserTarget.classList.add("hidden")
    }
}
