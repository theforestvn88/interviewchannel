import { Turbo, cable } from "@hotwired/turbo-rails";
import Sync from "./sync";
import CodeEditor from "./code_editor";
import P2pVideo from "./p2p_video";

const CodeComponent = "code";
const VideoComponent = "video";

class InterviewElement extends HTMLElement {
  async connectedCallback() {
    Turbo.connectStreamSource(this);
    const subscription = await cable.subscribeTo(this.channel, {
      received: this.dispatchMessageEvent.bind(this)
    });
		const upStream = new Sync(this.id, this.user_id, this.user_name, subscription);

		this.sync = (component, data) => {
			upStream.sync(component, data);
		}
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

  get channel() {
    const channel = this.getAttribute("channel");
    const signed_stream_name = this.getAttribute("signed-stream-name");
    return { channel, signed_stream_name };
  }

  get id() {
    return this.getAttribute("interview-id");
  }

  get user_id() {
    return this.getAttribute("user_id");
  }

  get user_name() {
    return this.getAttribute("user_name");
  }
}

customElements.define("interview-stream", InterviewElement);
