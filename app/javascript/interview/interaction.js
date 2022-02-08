class KeyInputHandler {
  constructor() {
    this.listerners = {};
  }

  addListener(key, listener) {
    this.listerners[key] = this.listerners[key] || [];
    this.listerners[key].push(listener);
  }

  exec(key, event) {
    if (this.listerners[key]) {
      this.listerners[key].forEach(handler => {
        handler(event);
      });
    }
  }
}

export {
  KeyInputHandler
}