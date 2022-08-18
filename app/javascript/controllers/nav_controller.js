import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [ "navbar", "navicon", "navcontent" ]

    connect() {
        this.visible = false
    }

    show() {
        this.navcontentTarget.classList.remove("-left-2/3", "max-w-0")
        this.naviconTarget.textContent = "X"
        this.navbarTarget.classList.add("w-full", "ml-64", "bg-white", "z-50")
        this.visible = true
    }
    
    hide() {
        this.navcontentTarget.classList.add("-left-2/3", "max-w-0")
        this.naviconTarget.textContent = "#"
        this.navbarTarget.classList.remove("w-full", "ml-64", "bg-white", "z-50")
        this.visible = false
    }

    toggle() {
        if (this.visible) {
            this.hide()
        } else {
            this.show()
        }
    }
}
