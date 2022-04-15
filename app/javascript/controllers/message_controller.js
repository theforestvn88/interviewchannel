import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["selectedTag", "content", "channel"]

    connect() {
        this.element.addEventListener("turbo:submit-end", this.clearForm.bind(this))
        this.selectedTag = null
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
        if (this.hasSelectedTagTarget) {
            this.selectedTagTarget.classList.remove("font-bold")
        }
        
        if (this.selectedTag) this.selectedTag.classList.remove("font-bold")
        event.target.classList.add("font-bold")
        this.selectedTag = event.target
    }
}