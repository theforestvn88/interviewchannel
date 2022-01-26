import { Turbo, cable } from "@hotwired/turbo-rails";
import { highlightCode } from "formatter"

class InterviewElement extends HTMLElement {
  async connectedCallback() {
    Turbo.connectStreamSource(this);
    this.subscription = await cable.subscribeTo(this.channel, {
      received: this.dispatchMessageEvent.bind(this)
    });

    let codeInput = this.querySelector("textarea");
    let codeEditor = this.querySelector(".code-editor");
    let codeHighlight = this.querySelector(".code-hl");

    codeInput.value = codeHighlight.firstChild.textContent;
    highlightCode(codeEditor, "ruby");
    
    codeInput.addEventListener('input', (e) => {
      let codeText = e.target.value;
      this.subscription.send({
        "code": codeText, 
        "id": this.getAttribute("interview-id"),
        "user": this.getAttribute("user")
      });
      codeHighlight.firstChild.textContent = codeText;
      highlightCode(codeEditor, "ruby");
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
      highlightCode(codeEditor, "ruby", true);
    }

    return this.dispatchEvent(event);
  }

  get channel() {
    const channel = this.getAttribute("channel");
    const signed_stream_name = this.getAttribute("signed-stream-name");
    return { channel, signed_stream_name };
  }
}

customElements.define("interview-stream", InterviewElement);
