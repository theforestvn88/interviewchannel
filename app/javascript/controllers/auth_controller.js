import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        let timezoneInput = document.getElementsByName("timezone")[0];
        timezoneInput.value = Intl.DateTimeFormat().resolvedOptions().timeZone;
    }

    processing() {
        const authContainter = document.getElementById("auth-containter")
        authContainter.style.display = "none"
        const processingView = document.getElementById("auth-processing")
        processingView.classList.remove("hidden")
    }
}
