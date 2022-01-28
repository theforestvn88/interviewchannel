import { Turbo, cable } from "@hotwired/turbo-rails";
import CodeEditor from "./code_editor";
import P2pVideo from "./p2p_video";

class InterviewElement extends HTMLElement {
  async connectedCallback() {
    Turbo.connectStreamSource(this);
    this.subscription = await cable.subscribeTo(this.channel, {
      received: this.dispatchMessageEvent.bind(this)
    });

    this.codeEditor = new CodeEditor(this);
    this.videoHandler = new P2pVideo(this);
  }

  disconnectedCallback() {
    Turbo.disconnectStreamSource(this);
    if (this.subscription) this.subscription.unsubscribe();
  }

  dispatchMessageEvent(data) {
    const event = new MessageEvent("message", { data });

    switch (data.component) {
      case "code":
        this.codeEditor.receive(data);
        break;
      case "video":
        this.videoHandler.receive(data);
        break;
      default:
        break;
    }

    return this.dispatchEvent(event);
  }

  sync(data) {
    this.subscription.send(data);
  }

  get channel() {
    const channel = this.getAttribute("channel");
    const signed_stream_name = this.getAttribute("signed-stream-name");
    return { channel, signed_stream_name };
  }

  get id() {
    return this.getAttribute("interview-id");
  }

  get user() {
    return this.getAttribute("user");
  }
}

customElements.define("interview-stream", InterviewElement);
