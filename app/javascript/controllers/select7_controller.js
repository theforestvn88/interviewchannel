import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [ "tagsContainer", "input", "suggestionTags" ]
    static values = { suggestApi: String, attr: String }

    connect() {
        this.timeoutId = null
        this.element.addEventListener("turbo:submit-end", this.clearForm.bind(this))
    }

    suggest() {
        if (this.timeoutId) {
            clearTimeout(this.timeoutId)
        }

        this.timeoutId = setTimeout(() => {
            let suggestQuery = this.suggestApiValue + `?key=${this.inputTarget.value}&attr=${this.attrValue}`
            fetch(suggestQuery)
                .then((r) => r.text())
                .then((html) => {
                    if (html != "") {
                        this.suggestionTagsTarget.innerHTML = html
                        this.suggestionTagsTarget.classList.remove("hidden")
                    } else {
                        this.suggestionTagsTarget.classList.add("hidden")
                    }
                })
        }, 200) // debounce 200
    }

    selectTag(e) {
        const selectedView = e.target.nextElementSibling
        this.tagsContainerTarget.appendChild(selectedView)
        selectedView.classList.remove("hidden")
        this.suggestionTagsTarget.innerHTML = ""
        this.suggestionTagsTarget.classList.add("hidden")
        this.inputTarget.value = ""
    }

    removeTag(e) {
        const removeView = e.target.parentElement
        this.tagsContainerTarget.removeChild(removeView)
    }

    clearForm() {
        this.tagsContainerTarget.innerHTML = ""
    }
}
