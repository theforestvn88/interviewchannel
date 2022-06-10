import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [ "clockView", "waitView" ]
    static values = { time: Number }

    connect() {
        this.countdown()

        var countdownId = setInterval(() => {
            this.timeValue -= 1
            if (this.timeValue < 0) {
                clearInterval(countdownId)

                this.clockViewTarget.classList.add("hidden")
                if (this.hasWaitViewTarget) {
                    this.waitViewTarget.classList.remove("hidden")
                }
            } else {
                this.countdown()
            }
        }, 1000)
    }

    countdown() {
        const daySeconds = 24 * 60 * 60
        const hourSeconds = 60 * 60
        const days = Math.floor(this.timeValue / daySeconds)
        const hours = Math.floor((this.timeValue % daySeconds) / hourSeconds)
        const minutes = Math.floor((this.timeValue % hourSeconds) / 60)
        const seconds = this.timeValue % 60
        this.clockViewTarget.textContent = `${days}d ${hours}h ${minutes}m ${seconds}s`
    }
}
