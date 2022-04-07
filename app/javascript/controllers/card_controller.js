import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["card"];
    static values = { url: String };

    show() {
        if (this.hasCardTarget) {
            this.cardTarget.classList.remove("hidden");
        } else if (this.urlValue) {
            if (this.existedCard()) {
                this.existedCard().classList.remove("hidden");
            } else {
                fetch(this.urlValue)
                    .then((r) => r.text())
                    .then((html) => {
                        const fragment = document.createRange().createContextualFragment(html);
                        this.element.appendChild(fragment);
                    });
            }
        }
    }

    hide() {
        if (this.hasCardTarget) {
            this.cardTarget.classList.add("hidden");
        }

        if (this.existedCard()) {
            this.existedCard().classList.add("hidden");
        }
    }

    existedCard() {
        this.byUrlCard = this.byUrlCard || document.getElementById(this.urlValue);
        return this.byUrlCard;
    }

    disconnect() {
        if (this.hasCardTarget) {
            this.cardTarget.remove();
        }
    }
}