import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [ "selected", "input", "suggestion", "template" ]
    static values = { suggestApi: String, name: String, multiple: Boolean }

    connect() {
        this.count = 0
        this.timeoutId = null
        this.element.addEventListener("turbo:submit-end", this.clearForm.bind(this))
    }

    suggest() {
        if (this.timeoutId) {
            clearTimeout(this.timeoutId)
        }

        this.timeoutId = setTimeout(() => {
            let searchKey = this.inputTarget.value
            let suggestQuery = this.suggestApiValue + `?key=${searchKey}`
            fetch(suggestQuery)
                .then((r) => r.text())
                .then((html) => {
                    if (html != "") {
                        this.suggestionTarget.innerHTML = html
                        this.suggestionTarget.classList.remove("hidden")
                    } else {
                        this.suggestionTarget.classList.add("hidden")
                    }
                })
        }, 200) // debounce 200
    }

    selectTag(e) {
        const selectedView = e.target

        const input = document.createElement("input")
        input.setAttribute("type", "hidden")
        input.setAttribute("value", selectedView.getAttribute("value"))

        if (this.multipleValue) {
            input.setAttribute("name", this.nameValue.replace("[0]", `[${this.count}]`))
            const selectedItem = this.templateTarget.cloneNode(true)
            selectedItem.appendChild(input)
            selectedItem.insertAdjacentHTML("afterbegin", selectedView.innerHTML)
            selectedItem.classList.remove("hidden")
            this.selectedTarget.appendChild(selectedItem)
            
            this.inputTarget.value = ""
        } else {
            input.setAttribute("name", this.nameValue)
            this.inputTarget.value = selectedView.getAttribute("selected-display")
            this.selectedTarget.innerHTML = ""
            this.selectedTarget.appendChild(input)
        }

        this.suggestionTarget.innerHTML = ""
        this.suggestionTarget.classList.add("hidden")

        this.count--
    }

    removeTag(e) {
        const removeView = e.target.parentElement

        if (removeView.hasAttribute("data-remove-id")) {
            const input = document.createElement("input")
            input.setAttribute("type", "hidden")
            input.setAttribute("name", removeView.getAttribute("data-remove-id"))
            input.setAttribute("value", removeView.getAttribute("data-remove-value"))

            this.selectedTarget.appendChild(input)
            removeView.querySelectorAll('input').forEach(v => this.selectedTarget.appendChild(v))
        }

        this.selectedTarget.removeChild(removeView)
    }

    clearForm() {
        this.selectedTarget.innerHTML = ""
    }
}
