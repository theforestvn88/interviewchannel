class KeyInputHandler {
  constructor(sourceElement) {
    this.listerners = {};
    this.afterCallbacks = {};
    this.beforeCallbacks = {};
    this.commands = [];
    this.combineKeys = {}; // TODO: bit

    sourceElement.addEventListener("input", e => {
      this.exec("Common", e);
    });

    sourceElement.addEventListener("keyup", e => {
      this.combineKeys[e.key] = false;

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
      this.combineKeys[e.key] = true;

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
        case "c":
          if (e.ctrlKey) {
            if (e.target.selectionStart == e.target.selectionEnd) {
              e.preventDefault();
              this.commands.push("CopyLine");
            } else if (this.commands[this.commands.length - 1] == "CopyLine") {
              this.commands.pop();
            }
          }
          break;
        case "v":
          if (e.ctrlKey && this.commands[this.commands.length - 1] == "CopyLine") {
            e.preventDefault();
            this.exec("CopyPasteLine", e);
          }
          break;
        case "z":
          if (e.ctrlKey) {
            e.preventDefault();
            this.exec("BackwardCode", e);
          }
          break;
        case "Z":
          if (e.ctrlKey) {
            e.preventDefault();
            this.exec("ForwardCode", e);
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
      this.afterCallbacks[key] = this.afterCallbacks[key] || [];
      this.afterCallbacks[key].push(callback); 
    }
  }

  before(keys = ["all"], callback) {
    for(let key of keys) {
      this.beforeCallbacks[key] = this.beforeCallbacks[key] || [];
      this.beforeCallbacks[key].push(callback); 
    }
  }

  addListener(key, listener) {
    this.listerners[key] = this.listerners[key] || [];
    this.listerners[key].push(listener);
  }

  exec(key, event) {
    if (this.listerners[key]) {
      this.listerners[key].forEach(handler => {
        [key, "all"].forEach(x => {
          if (this.beforeCallbacks[x]) {
            this.beforeCallbacks[x].forEach(callback => {
              callback(event);
            });
          }
        });

        let result = handler(event);

        [key, "all"].forEach(x => {
          if (this.afterCallbacks[x]) {
            this.afterCallbacks[x].forEach(callback => {
              callback(result);
            });
          }
        });
      });
    }
  }
}

export {
  KeyInputHandler
}