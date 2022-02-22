const InteractionStates = {
  Code: "Code",
  SearchFile: "SearchFile",
  Cmd: "Command",
  Run: "Run"
};

class KeyInputHandler {
  constructor(codeEditor) {
    this.listerners = {};
    this.afterCallbacks = {};
    this.beforeCallbacks = {};
    this.commands = [];
    this.combineKeys = {}; // TODO: bit

    this.currentState = InteractionStates.Code;

    codeEditor.addEventListener("input", e => {
      switch (this.currentState) {
        case InteractionStates.Code:
          this.exec("InputCode", e);
          break;
        
        case InteractionStates.SearchFile:
          this.exec("SearchFile", e);
          break;

        case InteractionStates.Cmd:
          this.exec("InputCommand", e);
          break;

        default:
          break;
      }
    });

    codeEditor.addEventListener("keyup", e => {
      this.combineKeys[e.key] = false;

      switch (e.key) {
        case "Enter":
          e.preventDefault();
          switch (this.currentState) {
            case InteractionStates.Code:
              this.exec("BreakLineCode", e);   
              break;
            
            case InteractionStates.SearchFile:
              this.exec("LoadSelectedFile", e);
              this.currentState = InteractionStates.Code;
              break;

            case InteractionStates.Cmd:
              this.exec("ExecCommand", e);
              this.currentState = InteractionStates.Code;
              break;

            default:
              break;
          }
          break;

				case "Escape":
					e.preventDefault();
          switch (this.currentState) {
            case InteractionStates.Code:
              this.exec("ReleaseLock", e);
              break;
          
            case InteractionStates.SearchFile:
            case InteractionStates.Cmd:
              this.exec("FocusCoding", e);
              this.currentState = InteractionStates.Code;
              break;

            default:
              break;
          }
          break;

        default:
          break;
      }
    });

    codeEditor.addEventListener("keydown", e => {
      this.combineKeys[e.key] = true;

      switch (e.key) {
        case "Tab":
          e.preventDefault();
          switch (this.currentState) {
            case InteractionStates.Code:
              if (e.shiftKey) {
                this.exec("ShiftTab", e);
              } else {
                this.exec("Tab", e);
              }
              break;
          
            default:
              break;
          }
          break;

        case "ArrowUp":
          switch (this.currentState) {
            case InteractionStates.Code:
              if (e.altKey) {
                e.preventDefault();
                this.exec("MoveLinesUp", e);
              }
              break;

            case InteractionStates.SearchFile:
              this.exec("SelectAboveFile", e);
              break;
          
            default:
              break;
          }
          break;

        case "ArrowDown":
          switch (this.currentState) {
            case InteractionStates.Code:
              if (e.altKey) {
                e.preventDefault();
                this.exec("MoveLinesDown", e);
              }
              break;

            case InteractionStates.SearchFile:
              this.exec("SelectBelowFile", e);
              break;
          
            default:
              break;
          }
          break;

        case "/":
          switch (this.currentState) {
            case InteractionStates.Code:
              if (e.ctrlKey) {
                e.preventDefault();
                this.exec("CommentLines", e);
              }
              break;
          
            default:
              break;
          }
          break;

        case "Delete":
          switch (this.currentState) {
            case InteractionStates.Code:
              if (e.shiftKey) {
                e.preventDefault();
                this.exec("DeleteLines", e);
              }
              break;
          
            default:
              break;
          }
          break;

        case "c":
          switch (this.currentState) {
            case InteractionStates.Code:
              if (e.ctrlKey) {
                if (e.target.selectionStart == e.target.selectionEnd) {
                  e.preventDefault();
                  this.commands.push("CopyLine");
                } else if (this.commands[this.commands.length - 1] == "CopyLine") {
                  this.commands.pop();
                }
              }
              break;
          
            default:
              break;
          }
          break;

        case "v":
          switch (this.currentState) {
            case InteractionStates.Code:
              if (e.ctrlKey && this.commands[this.commands.length - 1] == "CopyLine") {
                e.preventDefault();
                this.exec("CopyPasteLine", e);
              }   
              break;
          
            default:
              break;
          }
          break;

        case "z":
          switch (this.currentState) {
            case InteractionStates.Code:
              if (e.ctrlKey) {
                e.preventDefault();
                this.exec("BackwardCode", e);
              }              
              break;
          
            default:
              break;
          }
          break;

        case "Z":
          switch (this.currentState) {
            case InteractionStates:
              if (e.ctrlKey) {
                e.preventDefault();
                this.exec("ForwardCode", e);
              }
              break;
          
            default:
              break;
          }
          break;

        case ":":
          switch (this.currentState) {
            case InteractionStates.Code:
              if (e.shiftKey) {
                e.preventDefault();
                this.exec("OpenCommand", e);
                this.currentState = InteractionStates.Cmd;
              }              
              break;
          
            default:
              break;
          }
          break;

        case "p":
          switch (this.currentState) {
            case InteractionStates.Code:
              if (e.ctrlKey) {
                e.preventDefault();
                this.exec("OpenSearchFile", e);
                this.currentState = InteractionStates.SearchFile;
              }
              break;
          
            default:
              break;
          }
          break;

        case "Backspace":
          e.preventDefault();
          switch (this.currentState) {
            case InteractionStates.Code:
              this.exec("DeleteCodeChar", e);
              break;

            case InteractionStates.SearchFile:
              this.exec("DeleteSearchChar", e);
              break;
            
            case InteractionStates.Cmd:
              this.exec("DeleteCommandChar", e);
              break;

            default:
              break;
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
        if (!result) return;

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

// client side command executor
// parsing input then dispatch commands
class Commander {
  constructor(clientExecutor, serverExecutor) {
    this.clientExecutor = clientExecutor;
    this.serverExecutor = serverExecutor;
  }

  exec(command) {
    let [cmdName, ...cmdArguments] = command.split(" ");
    switch (cmdName) {
      case ":theme":
        this.clientExecutor.switchTheme(cmdArguments[0]);
        break;
      case ":touch":
        cmdArguments.forEach(file => {
          this.clientExecutor.createFile(file);
        });
        break;
      default:
        break;
    }
  }
}

// run code remote from server
class Runner {}

export {
  KeyInputHandler,
  Commander,
  Runner
}
