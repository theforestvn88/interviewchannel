import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = { url: String }

    connect() {
        this.connected = true
        this.load()
    }

    disconnect() {
        this.connected = false
    }

    load() {
        fetch(this.urlValue)
            .then(response => response.text())
            .then(html => this.apply(html))
    }

    apply(html) {
        if (!this.connected) return;
        this.element.innerHTML = html
    }
}
