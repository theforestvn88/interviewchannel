import { Turbo, cable } from "@hotwired/turbo-rails";
import { highlightCode } from "formatter"

class InterviewElement extends HTMLElement {
  async connectedCallback() {
    Turbo.connectStreamSource(this);
    this.subscription = await cable.subscribeTo(this.channel, {
      received: this.dispatchMessageEvent.bind(this)
    });

    let langSelect = this.querySelector("#lang");
    langSelect.addEventListener('change', (e) => {
      this.lang = e.target.value;
      highlightCode(codeEditor, this.lang);
    });

    let styleSelect = this.querySelector("#style");
    styleSelect.addEventListener('change', (e) => {
      this.style = e.target.value;
      for (let link of document.querySelectorAll(".codestyle")) {
        link.disabled = !link.href.match(this.style + "\\.min.css$");
      }
      highlightCode(codeEditor, this.lang);
    });

    let codeInput = this.querySelector("textarea");
    let codeEditor = this.querySelector(".code-editor");
    let codeHighlight = this.querySelector(".code-hl");

    codeInput.value = codeHighlight.firstChild.textContent;
    highlightCode(codeEditor, this.lang);
    
    codeInput.addEventListener('input', (e) => {
      let codeText = e.target.value;
      this.subscription.send({
        "code": codeText, 
        "id": this.getAttribute("interview-id"),
        "user": this.getAttribute("user")
      });
      codeHighlight.firstChild.textContent = codeText;
      highlightCode(codeEditor, this.lang);
    });
  }

  disconnectedCallback() {
    Turbo.disconnectStreamSource(this);
    if (this.subscription) this.subscription.unsubscribe();
  }

  dispatchMessageEvent(data) {
    const event = new MessageEvent("message", { data });

    if (data.user != this.getAttribute("user")) {
      let codeEditor = this.querySelector(".code-editor");
      let codeHighlight = this.querySelector(".code-hl");
      codeHighlight.firstChild.textContent = data.code;
      highlightCode(codeEditor, this.lang, true);
    }

    return this.dispatchEvent(event);
  }

  get channel() {
    const channel = this.getAttribute("channel");
    const signed_stream_name = this.getAttribute("signed-stream-name");
    return { channel, signed_stream_name };
  }

  get lang() {
    if (!this.selectedLang) {
      this.selectedLang = this.getAttribute("language") || "ruby";
    }

    return this.selectedLang;
  }

  set lang(language) {
    this.selectedLang = language;
  }

  get style() {
    if (!this.selectedStyle) {
      this.selectedStyle = this.getAttribute("style") || "default";
    }

    return this.selectedStyle;
  }

  set style(_style) {
    this.selectedStyle = _style;
  }
}

customElements.define("interview-stream", InterviewElement);
