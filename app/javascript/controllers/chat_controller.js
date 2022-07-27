import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { room: String, channel: String, message: String, url: String}

  connect() {
    if (this.appendMessage()) {
      this.element.remove()
    } else {
      fetch(this.urlValue)
        .then((r) => r.text())
        .then((html) => {
          setTimeout(() => {
            this.appendMessage()
            this.element.remove()
          }, 500);
        });
    }
  }

  appendMessage() {
    const existedRoom = document.getElementById(this.roomValue)
    if (existedRoom) {
      const chatRoom = existedRoom.firstElementChild
      chatRoom.classList.remove("hidden")
      const messages = chatRoom.querySelector(`#${this.channelValue}`)
      messages.insertAdjacentHTML("beforeend", `<p>${this.messageValue}</p>`)
      return true
    }

    return false
  }
}