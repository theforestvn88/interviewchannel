import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [ "userToolbar" ]

    connect() {
        this.openUserToolbar = false
    }

    showUserToolbar() {
        this.userToolbarTarget.classList.remove("hidden")
        this.openUserToolbar = true
    }
    
    hideUserToolbar() {
        this.userToolbarTarget.classList.add("hidden")
        this.openUserToolbar = false
    }

    hideUserToolbarIfShow() {
        if (this.openUserToolbar) {
            this.hideUserToolbar()
        }
    }

    toggleUserToolbar(e) {
        if (this.openUserToolbar) {
            this.hideUserToolbar()
        } else {
            this.showUserToolbar()
        }

        e.stopPropagation()
    }
}
