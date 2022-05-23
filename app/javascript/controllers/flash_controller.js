import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [ "flashView" ]

    connect() {
        setTimeout(() => {
            this.hide()
        }, 5000)
    }

    hide() {
        this.flashViewTarget.classList.add("hidden")
    }
}