import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["content", "channel"]
    connect() {
        this.element.addEventListener("turbo:submit-end", this.clearForm.bind(this))
        this.selectedTagView = document.getElementById("form_tag_all")
        this.selectedTagView.classList.add("bg-green-600")
    }

    clearForm() {
        if (this.hasContentTarget) {
            this.contentTarget.value = ""
        }

        if (this.hasChannelTarget) {
            this.channelTarget.value = ""
        }
    }

    selectTag(event) {
        if (this.selectedTagView) this.selectedTagView.classList.remove("bg-green-600")
        event.target.classList.remove("font-bold")
        this.selectedTagView = event.target.closest("form")
        this.selectedTagView.classList.add("bg-green-600")
    }
}