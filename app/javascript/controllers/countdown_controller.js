import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = { time: Number, redirecturl: String }

    connect() {
        this.countdown()

        var countdownId = setInterval(() => {
            this.timeValue -= 1
            this.countdown()
            if (this.timeValue <= 0) {
                clearInterval(countdownId)
                location.reload()
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
        this.element.textContent = `${days} day(s) :: ${hours} hour(s) :: ${minutes} minute(s) :: ${seconds} second(s)`
    }
}
