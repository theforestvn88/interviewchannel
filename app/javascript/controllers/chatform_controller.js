import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { room: String }

  connect() {
    if (this.hasRoomValue) {
      const existedRoom = document.getElementById(this.roomValue)
      if (!existedRoom) {
        const chatRooms = document.getElementById("chat-rooms")
        chatRooms.insertAdjacentHTML("afterbegin", this.element.innerHTML)
      }

      this.element.remove()
    }
  }
}