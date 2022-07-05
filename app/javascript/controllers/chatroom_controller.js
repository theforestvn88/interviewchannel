import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "form" ]
  static values = { open: Boolean }

  connect() {}

  show(e) {
    this.formTarget.classList.remove("hidden")
    this.openValue = true
  }

  hide(e) {
    this.formTarget.classList.add("hidden")
    this.openValue = false
  }

  toggle(e) {
    if (this.openValue) {
      this.hide(e)
    } else {
      this.show(e)
    }
  }

  close(e) {
    this.hide()
    this.element.classList.add("hidden")
  }  
}