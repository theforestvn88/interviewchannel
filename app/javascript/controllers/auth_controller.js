import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        let timezoneInput = document.getElementsByName("timezone")[0];
        timezoneInput.value = Intl.DateTimeFormat().resolvedOptions().timeZone;
    }
}
