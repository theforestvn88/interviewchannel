import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [ "userToolbar" ]

    connect() {
        this.openUserToolbar = false
    }

    toggleUserToolbar() {
        if (this.openUserToolbar) {
            this.userToolbarTarget.classList.add("hidden")
            this.openUserToolbar = false
        } else {
            this.userToolbarTarget.classList.remove("hidden")
            this.openUserToolbar = true
        }
    }
}
