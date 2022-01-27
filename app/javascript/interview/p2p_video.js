// Broadcast Types
const OPEN_VIDEO = "OPEN_VIDEO";
const EXCHANGE = "EXCHANGE";
const CLOSE_VIDEO = "CLOSE_VIDEO";

// Ice Credentials
const ice = { iceServers: [{ urls: "stun:stun.l.google.com:19302" }] }

const logError = (error) => console.warn("Whoops! Error:", error);

export default class P2pVideo {
  // DOM Elements
  #localVideo;
  #remoteVideoContainer;

  // Objects
  #pcPeers = {};
  #localstream;

  constructor(interviewId, user, broadcaster) {
    this.interview = interviewId;
    this.currentUser = user;
    this.broadcaster = broadcaster;

    this.#localVideo = document.getElementById("local-video");
    this.#remoteVideoContainer = document.getElementById("remote-video-container");

    this.openLocalVideo();
    document.getElementById("open-video").onclick = () => {
      this.requestRemoteVideo();
    }
  }

  openLocalVideo() {
    navigator.mediaDevices
      .getUserMedia({
        audio: true,
        video: true
      })
      .then(stream => {
        this.#localstream = stream;
        this.#localVideo.srcObject = stream;
        this.#localVideo.muted = true;
      })
      .catch(logError);
  }

  requestRemoteVideo() {
    this.broadcaster.send({
      component: "video",
      id: this.interview,
      type: OPEN_VIDEO,
      from: this.currentUser
    });
  }

  receive(data) {
    console.log("received", data);
    // if (data.from === this.currentUser) return;
    switch (data.type) {
      case OPEN_VIDEO:
        return this.createPC(data.from, true);
      case EXCHANGE:
        if (data.to !== this.currentUser) return;
        return this.exchange(data);
      case CLOSE_VIDEO:
        return this.removeUser(data);
      default:
        return;
    }
  }

  createPC(userId, isOffer) {
    let pc = new RTCPeerConnection(ice);
    const element = document.createElement("video");
    element.id = `remoteVideoContainer+${userId}`;
    element.autoplay = "autoplay";
    this.#remoteVideoContainer.appendChild(element);

    this.#pcPeers[userId] = pc;

    for (const track of this.#localstream.getTracks()) {
      pc.addTrack(track, this.#localstream);
    }

    isOffer &&
      pc
        .createOffer()
        .then(offer => {
          return pc.setLocalDescription(offer);
        })
        .then(() => {
          this.broadcaster.send({
            component: "video",
            id: this.interview,
            type: EXCHANGE,
            from: this.currentUser,
            to: userId,
            sdp: JSON.stringify(pc.localDescription)
          });
        })
        .catch(logError);

    pc.onicecandidate = event => {
      event.candidate &&
        this.broadcaster.send({
          component: "video",
          id: this.interview,
          type: EXCHANGE,
          from: this.currentUser,
          to: userId,
          candidate: JSON.stringify(event.candidate)
        });
    };

    pc.ontrack = event => {
      if (event.streams && event.streams[0]) {
        element.srcObject = event.streams[0];
      } else {
        let inboundStream = new MediaStream(event.track);
        element.srcObject = inboundStream;
      }
    };

    pc.oniceconnectionstatechange = () => {
      if (pc.iceConnectionState == "disconnected") {
        console.log("Disconnected:", userId);
        this.broadcaster.send({
          component: "video",
          id: this.interview,
          type: CLOSE_VIDEO,
          from: userId
        });
      }
    };

    return pc;
  }

  exchange(data) {
    let pc;

    if (!this.#pcPeers[data.from]) {
      pc = this.createPC(data.from, false);
    } else {
      pc = this.#pcPeers[data.from];
    }

    if (data.candidate) {
      pc.addIceCandidate(new RTCIceCandidate(JSON.parse(data.candidate)))
        .then(() => console.log("Ice candidate added"))
        .catch(logError);
    }

    if (data.sdp) {
      const sdp = JSON.parse(data.sdp);
      pc.setRemoteDescription(new RTCSessionDescription(sdp))
        .then(() => {
          if (sdp.type === "offer") {
            pc.createAnswer()
              .then(answer => {
                return pc.setLocalDescription(answer);
              })
              .then(() => {
                this.broadcaster.send({
                  component: "video",
                  id: this.interview,
                  type: EXCHANGE,
                  from: this.currentUser,
                  to: data.from,
                  sdp: JSON.stringify(pc.localDescription)
                });
              });
          }
        })
        .catch(logError);
    }
  }

  userOut() {
    for (let user in this.#pcPeers) {
      this.#pcPeers[user].close();
    }
    this.#pcPeers = {};

    this.#remoteVideoContainer.innerHTML = "";

    this.broadcaster.send({
      component: "video",
      id: this.interview,
      type: CLOSE_VIDEO,
      from: this.currentUser
    });
  }

  removeUser(data) {
    console.log("removing user", data.from);
    let video = document.getElementById(`remoteVideoContainer+${data.from}`);
    video && video.remove();
    delete this.#pcPeers[data.from];
  }
}