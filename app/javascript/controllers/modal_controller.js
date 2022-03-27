import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [ "modal" ]

    connect() {
        document.addEventListener("turbo:submit-end", this.afterSubmit)
    }

    disconnect() {
        document.removeEventListener("turbo:submit-end", this.afterSubmit)
    }

    close() {
        this.modalTarget.parentElement.removeAttribute("src")
        this.modalTarget.remove()
    }

    afterSubmit = (e) => {
        if (e.detail.success) {
            this.close();
        }
    }

    handleKeyup(e) {
        if (e.code == "Escape") {
            this.close();
        }
    }
}
