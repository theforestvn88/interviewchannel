import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["card"]
    static values = { url: String }

    connect() {
      this.hidden = true
    }

    show() {
        if (this.hasCardTarget) {
            this.showCard(this.cardTarget)
        } else if (this.urlValue) {
            if (this.existedCard()) {
                this.showCard(this.existedCard())
            } else {
                fetch(this.urlValue)
                    .then((r) => r.text())
                    .then((html) => {
                        const fragment = document.createRange().createContextualFragment(html)
                        this.element.appendChild(fragment)
                        if (!this.hidden) this.hide()
                    });
            }
        }
    }

    hide(e) {
        const card = this.hasCardTarget ? this.cardTarget : this.existedCard()
        this.hideCard(card)
    }

    lostFocus(e) {
      if (e && this.element.contains(e.target)) {
        return
      }

      this.hide(e)
    }

    existedCard() {
        this.byUrlCard = this.byUrlCard || document.getElementById(this.urlValue)
        return this.byUrlCard
    }

    showCard(card) {
        if (card) card.classList.remove("hidden")
        this.hidden = false
    }

    hideCard(card) {
        if (card) card.classList.add("hidden")
        this.hidden = true
    }

    disconnect() {
        if (this.hasCardTarget) {
            this.cardTarget.remove()
        }
    }

    toggle(e) {
      if (this.hasCardTarget) {
        e.preventDefault();

        if (this.hidden) {
          this.showCard(this.cardTarget)
        } else {
          this.hideCard(this.cardTarget)
        }

        
      }
    }
}