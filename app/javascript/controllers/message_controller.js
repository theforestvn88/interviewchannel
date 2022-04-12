import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["content", "channel"]

    connect() {
        this.element.addEventListener("turbo:submit-end", this.clearForm.bind(this));
    }

    recently() {
        fetch('/messages')
            .then(r => r.text())
            .then(html => {
                const fragment = document.createRange().createContextualFragment(html)
                document.getElementById("home-content").replaceWith(fragment)
            })
    }

    clearForm() {
        this.contentTarget.value = ""
        this.channelTarget.value = ""
    }
}