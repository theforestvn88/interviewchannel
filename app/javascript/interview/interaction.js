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
    this.currentState = InteractionStates.Code;
    
    // key input event chain: keydown -> keyup -> input
    // keydown: handle specific command 
    // input: normal input
    // ...

    codeEditor.addEventListener("keydown", e => {
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

        case ";":
          switch (this.currentState) {
            case InteractionStates.Code:
              if (e.ctrlKey) {
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
          switch (this.currentState) {
            case InteractionStates.SearchFile:
              e.preventDefault();
              this.exec("DeleteSearchChar", e);
              break;
            
            case InteractionStates.Cmd:
              e.preventDefault();
              this.exec("DeleteCommandChar", e);
              break;

            default:
              break;
          }
          break;

        case "Enter":
          switch (this.currentState) {            
            case InteractionStates.SearchFile:
              e.preventDefault();
              this.exec("LoadSelectedFile", e);
              this.currentState = InteractionStates.Code;
              break;

            case InteractionStates.Cmd:
              e.preventDefault();
              this.exec("ExecCommand", e);
              this.currentState = InteractionStates.Cmd;
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

    codeEditor.addEventListener("input", e => {
      switch (this.currentState) {
        case InteractionStates.Code:
          if (e.data) {
            this.exec("InputCode", e.data);
          } else {
            this.exec("InputCode", e.inputType);
          }
          break;
        
        case InteractionStates.SearchFile:
          if (e.data) {
            this.exec("SearchFile", e.data);
          }
          break;

        case InteractionStates.Cmd:
          if (e.data) {
            this.exec("InputCommand", e.data);
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
  constructor(executor) {
    this.executor = executor;
  }

  exec(command) {
    let [cmdName, ...cmdArguments] = command.split(" ");
    switch (cmdName) {
      case ":theme":
        this.executor.switchTheme(cmdArguments[0]);
        break;

      case ":touch":
        cmdArguments.forEach(file => {
          this.executor.createFile(file);
        });
        break;
        
      case ":run":
        this.executor.run(cmdArguments);
        break;

      default:
        break;
    }
  }
}

export {
  KeyInputHandler,
  Commander
}
