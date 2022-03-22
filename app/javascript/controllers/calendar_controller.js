import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {}

  changeDate(event) {
    event.target.closest("form").requestSubmit();
  }
}
