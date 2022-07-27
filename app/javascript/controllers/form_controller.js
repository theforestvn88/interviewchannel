import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [ "confirmDialog" ]

    connect() {
        this.timeZone = Intl.DateTimeFormat().resolvedOptions().timeZone
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
}
