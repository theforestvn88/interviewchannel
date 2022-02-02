import { Turbo, cable } from "@hotwired/turbo-rails";
import CodeEditor from "./code_editor";
import P2pVideo from "./p2p_video";

const CodeComponent = "code";
const VideoComponent = "video";

class InterviewElement extends HTMLElement {
  async connectedCallback() {
    Turbo.connectStreamSource(this);
    this.subscription = await cable.subscribeTo(this.channel, {
      received: this.dispatchMessageEvent.bind(this)
    });

    this.codeEditor = new CodeEditor(this, CodeComponent);
    this.videoHandler = new P2pVideo(this, VideoComponent);
  }

  disconnectedCallback() {
    Turbo.disconnectStreamSource(this);
    if (this.subscription) this.subscription.unsubscribe();
  }

  dispatchMessageEvent(data) {
    const event = new MessageEvent("message", { data });

    switch (data.component) {
      case CodeComponent:
        this.codeEditor.receive(data);
        break;
      case VideoComponent:
        this.videoHandler.receive(data);
        break;
      default:
        break;
    }

    return this.dispatchEvent(event);
  }

  sync(component, data) {
    this.subscription.send({
      id: this.id,
      user: this.user,
      component: component,
      ...data
    });
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
