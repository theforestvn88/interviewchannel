import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [ "limitInput", "limitWarning" ]
    static values = { limit: Number }

    connect() {
        this.limitCharacters()
    }

    limitCharacters() {
        const chacractersCount = this.limitInputTarget.value.length
        if (chacractersCount > this.limitValue) {
            this.limitInputTarget.value = this.limitInputTarget.value.substring(0, this.limitValue)
            this.limitWarningTarget.classList.add("text-red-600")
        } else {
            this.limitWarningTarget.textContent = `${chacractersCount}/${this.limitValue} characters`
            this.limitWarningTarget.classList.remove("text-red-600")
        }
    }
}
