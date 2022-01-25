import { Turbo, cable } from "@hotwired/turbo-rails";
import { highlightCode } from "formatter"

class InterviewElement extends HTMLElement {
  async connectedCallback() {
    Turbo.connectStreamSource(this);
    this.subscription = await cable.subscribeTo(this.channel, {
      received: this.dispatchMessageEvent.bind(this)
    });

    let codeInput = this.querySelector("textarea");
    console.log(codeInput);

    let codeEditor = this.querySelector(".code-editor");
    console.log(codeEditor);
    let codeHighlight = this.querySelector(".code-hl");
    console.log(codeHighlight);
    codeInput.value = codeHighlight.firstChild.textContent;

    highlightCode(codeEditor);
    
    codeInput.addEventListener('input', (e) => {
      let codeText = e.target.value;
      console.log(codeText);
      this.subscription.send({"code": codeText});
      codeHighlight.firstChild.textContent = codeText;//.replace(/\r\n/g, '\n');
      highlightCode(codeEditor);
      // codeInput.selectionEnd = codeText.length;
    });

    // setTimeout(() => {
    //   console.log("CLIENT send a message");
    //   this.subscription.send({"code": this.innerText});
    // }, 5000);
  }

  disconnectedCallback() {
    Turbo.disconnectStreamSource(this);
    if (this.subscription) this.subscription.unsubscribe();
  }

  dispatchMessageEvent(data) {
    const event = new MessageEvent("message", { data });
    return this.dispatchEvent(event);
  }

  get channel() {
    const channel = this.getAttribute("channel");
    const signed_stream_name = this.getAttribute("signed-stream-name");
    return { channel, signed_stream_name };
  }
}

customElements.define("interview-stream", InterviewElement);
