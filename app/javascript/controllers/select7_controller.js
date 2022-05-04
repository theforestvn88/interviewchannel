import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [ "tagsContainer", "input", "suggestionTags" ]
    static values = { suggestApi: String, attr: String }

    connect() {}

    suggest() {
        let suggestQuery = this.suggestApiValue + `?key=${this.inputTarget.value}&attr=${this.attrValue}`
        fetch(suggestQuery)
            .then((r) => r.text())
            .then((html) => {
                this.suggestionTagsTarget.innerHTML = html
                this.suggestionTagsTarget.classList.remove("hidden")
            })
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
}
