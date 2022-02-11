class KeyInputHandler {
  constructor(sourceElement) {
    this.listerners = {};
    this.callbacks = {};

    sourceElement.addEventListener("input", e => {
      this.exec("Common", e);
    });

    sourceElement.addEventListener("keyup", e => {
      switch (e.key) {
        case "Enter":
          e.preventDefault();
          this.exec("Enter", e);
          break;
        default:
          break;
      }
    });

    sourceElement.addEventListener("keydown", e => {
      switch (e.key) {
        case "Tab":
          e.preventDefault();
          if (e.shiftKey) {
            this.exec("ShiftTab", e);
          } else {
            this.exec("Tab", e);
          }
          break;
        case "ArrowUp":
          if (e.altKey) {
            e.preventDefault();
            this.exec("MoveLinesUp", e);
          }
          break;
        case "ArrowDown":
          if (e.altKey) {
            e.preventDefault();
            this.exec("MoveLinesDown", e);
          }
          break;
        case "/":
          if (e.ctrlKey) {
            e.preventDefault();
            this.exec("CommentLines", e);
          }
          break;
        case "Delete":
          if (e.shiftKey) {
            e.preventDefault();
            this.exec("DeleteLines", e);
          }
          break;
        default:
          break;
      }
    });
  }

  // after callback
  after(keys = ["all"], callback) {
    for(let key of keys) {
      this.callbacks[key] = this.callbacks[key] || [];
      this.callbacks[key].push(callback); 
    }
  }

  addListener(key, listener) {
    this.listerners[key] = this.listerners[key] || [];
    this.listerners[key].push(listener);
  }

  exec(key, event) {
    if (this.listerners[key]) {
      this.listerners[key].forEach(handler => {
        let result = handler(event);
        [key, "all"].forEach(x => {
          if (this.callbacks[x]) {
            this.callbacks[x].forEach(callback => {
              callback(result);
            });
          }
        })
      });
    }
  }
}

export {
  KeyInputHandler
}