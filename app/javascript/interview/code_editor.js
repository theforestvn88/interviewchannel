import * as Formatter from "formatter";
import { KeyInputHandler, Commander } from "./interaction";
import History from "./history";
import Theme from "./theme";

export default class CodeEditor {
  static SLOGAN = "in code we trust !!!";
  static InitNumOfLines = 10;
	static LOCKTIME = 3000; // 3s
  static States = {
    Code: "Code",
    Cmd: "Command",
    Run: "Run"
  };
  static ModifyCodeEvents = [
	  "Input", 
	  "Enter", 
	  "Tab", 
	  "ShiftTab", 
	  "MoveLinesUp", 
	  "MoveLinesDown", 
	  "CommentLines", 
	  "DeleteLines", 
	  "CopyPasteLine"
  ];
  static DecoratingEvents = [
	  "Enter"
  ];
  static SyncCodeEvents = [
		...CodeEditor.ModifyCodeEvents
  ];

  constructor(interview, component) {
    this.interview = interview;
    this.component = component;
    this.history = new History();
    this.commander = new Commander(this, this);

    this.codeInput = this.interview.querySelector(".code-input");
    this.codeEditor = this.interview.querySelector(".code-editor");
    this.codeHighlight = this.interview.querySelector(".code-hl");
    this.commandLine = this.interview.querySelector("#editor-command");

    this.keyInputHandler = new KeyInputHandler(this.codeInput);
		// after modifying code callbacks  
    this.keyInputHandler.after(CodeEditor.ModifyCodeEvents, ([formattedCode, selectionStart, selectionEnd]) => {
      if (this.currentState !== CodeEditor.States.Code) return;

      this.codeInput.value = formattedCode;
      this.codeInput.setSelectionRange(selectionStart, selectionEnd);
      this.highlightCode(formattedCode);
      this.history.push(formattedCode);
    });
		// decorating editor callbacks
		this.keyInputHandler.after(CodeEditor.DecoratingEvents, ([formattedCode, s, e]) => {
      if (this.currentState !== CodeEditor.States.Code) return;

			this.updateCodeOverlay();
			if (this.currLineIndex == this.totalLines - 1) {
				this.highlightLineOfCode(this.totalLines);
				this.currLineIndex = this.totalLines;
			}
		});
		// sync code callbacks
		this.keyInputHandler.after(CodeEditor.SyncCodeEvents, ([formattedCode, s, e]) => {
			if (this.lockTime && this.lockTime > Date.now()) return;

			this.lockTime = null;
			this.interview.sync(this.component, {
				code: formattedCode
			})
		});

		this.setupEditor();

		// lockTime
		// 	update when someone is coding
		// 	expired when longtime no one coding or release lock
		this.lockTime = null; // default no lock
	}

  get lang() {
    if (!this.selectedLang) {
      this.selectedLang = this.interview.getAttribute("language") || "ruby";
    }

    return this.selectedLang;
  }

  set lang(language) {
    this.selectedLang = language;
  }

  get theme() {
    if (!this.currentTheme) {
      this.currentTheme = Theme.instanceOf(this.interview.getAttribute("theme"));
    }

    return this.currentTheme;
  }

  set theme(theme) {
    this.currentTheme = theme;
  }

  switchTheme(theme) {
    if (theme == this.theme.name) return;

    let oldTheme = this.theme;
    let newTheme = Theme.instanceOf(theme);
    if (!newTheme) return;

    this.theme = newTheme;
    
    this.switchHighlightTheme();

    ["main", "header", "command", "intro", "codeline-hl", "codeline-marked", "numline"].forEach(part => {
      let oldCssClass = `${oldTheme.name}-${part}`;
      let newCssClass = `${newTheme.name}-${part}`;
      for (let element of document.querySelectorAll(`.${oldCssClass}`)) {
        element.classList.remove(oldCssClass);
        element.classList.add(newCssClass);
      }
    })

    this.codeInput.classList.remove(`${oldTheme.name}-caret`);
    this.codeInput.classList.add(`${newTheme.name}-caret`);
    this.interview.querySelector("#editor-theme").textContent = `@${theme}`;
  }

  receive(data) {
    if (data.user != this.interview.user) {
      if (data.code) {
        this.codeInput.value = data.code;
        this.highlightCode(data.code);
        this.updateCodeOverlay(data);
      }

      if (data.actions) {
        this.showActions(data.actions);
      }
			
			if (data.lockTime) { // manual release lock (press ESC) - set locktime < now
				this.lockTime = data.lockTime;
			} else {
				// set lock expire-time
				this.lockTime = Date.now() + CodeEditor.LOCKTIME;
			}
    }
  }

  setupEditor() {
    // TODO: allow user create file then detecting @lang by the file extension.

    this.switchHighlightTheme();
    this.updateSologan();
    this.highlightCode();
    this.focusCoding();

    this.currLineIndex = 2;
    this.currMarkLineIndexes = [];
    this.totalLines = CodeEditor.InitNumOfLines;
    for(let i = 1; i <= this.totalLines; i++) {
      this.addOnLineNumberClickListener(i);
    }

    this.addEditorRules();
  }

  focusCoding() {
    this.currentState = CodeEditor.States.Code;
    this.codeInput.classList.remove("caret-transparent");
    this.codeInput.classList.add(`${this.currentTheme.name}-caret`);
    this.codeInput.focus();
  }

  switchHighlightTheme() {
    for (let link of document.querySelectorAll(".codestyle")) {
      link.disabled = !link.href.match(this.theme.config.highlight + "\\.min.css$");
    }
  }

  highlightCode(code = null) {
    if (code) {
      this.codeHighlight.firstChild.textContent = code;
    }
    Formatter.highlightCodeElement(this.codeEditor, this.lang);
  }

  updateSologan() {
    if (!this.codeInput.value) {
      const sologan = Formatter.commentOut(this.lang, `${CodeEditor.SLOGAN}\n`);
      this.codeHighlight.firstChild.textContent = sologan;
      this.codeInput.value = sologan;
    } else {
      if (this.codeInput.value.match(CodeEditor.SLOGAN)) {
        let firstNewLineIndex = this.codeInput.value.indexOf("\n");
        this.codeInput.value = 
          Formatter.commentOut(this.lang, CodeEditor.SLOGAN) +
          this.codeInput.value.substring(firstNewLineIndex);
        this.codeHighlight.firstChild.textContent = this.codeInput.value;
      }
    }
  }

  updateCodeOverlay() {
    let updateTotalLines = this.countNumOfLines();
    while (updateTotalLines > this.totalLines) {
      this.totalLines += 1;
      this.addLine(this.totalLines);
      this.expandHeight();
    }
  }

  showActions(actions) {
    for(let act of actions) {
			if (act.marklines) {
				this.resetMarkLinesOfCode();
				for(let i of act.marklines) {
					this.markLineOfCode(i);
				}
			}	
		}
  }

  addLine(lineIndex) {
    let codeOverlay = this.interview.querySelector(".code-editor-overlay");
    let lineView = document.createElement("div");
    lineView.id = `row-${lineIndex}`;
    lineView.classList.add("code-line");
    let numView = document.createElement("div");

    numView.id = `row-lineindex-${lineIndex}`;
    numView.classList.add("w-6", "flex", "justify-end");

    let numLabel = document.createElement("label");
    numLabel.classList.add("text-xs");
    numLabel.textContent = `${lineIndex}`;
    let sepLabel = document.createElement("label");
    sepLabel.textContent = "|";
    numView.appendChild(numLabel);
    numView.appendChild(sepLabel);

    lineView.appendChild(numView);
    codeOverlay.appendChild(lineView);

    this.addOnLineNumberClickListener(lineIndex, numView);
  }

  countNumOfLines(from = 0, to = undefined) {
    let codeText = this.codeInput.value;
    return (codeText.substring(from, to).match(/\n/g) || []).length + 1;
  }

  expandHeight() {
    this.codeInput.rows = this.totalLines;

    this.codeEditor.style.height = 'auto';
    this.codeEditor.style.height = this.codeEditor.scrollHeight + 'px';

    this.codeHighlight.style.height = 'auto';
    this.codeHighlight.style.height = this.codeHighlight.scrollHeight + 'px';
  }

  highlightLineOfCode(lineIndex) {
    if (this.currLineIndex) {
      this.interview
        .querySelector(`#row-${this.currLineIndex}`)
        .classList.remove(`${this.theme.name}-codeline-hl`);
    }

    let curLineView = this.interview.querySelector(`#row-${lineIndex}`);
    if (curLineView) {
      curLineView.classList.add(`${this.theme.name}-codeline-hl`);
      this.currLineIndex = lineIndex;
    }
  }

  resetMarkLinesOfCode() {
    for(let markLineIndex of this.currMarkLineIndexes) {
      this.interview
        .querySelector(`#row-${markLineIndex}`)
        .classList.remove(`${this.theme.name}-codeline-hl`, `${this.theme.name}-codeline-marked`);
    }

    this.currMarkLineIndexes = [];
  }

  markLineOfCode(lineIndex) {
    let curLineView = this.interview.querySelector(`#row-${lineIndex}`);
    if (curLineView) {
      curLineView.classList.add(`${this.theme.name}-codeline-marked`);
      this.currMarkLineIndexes.push(lineIndex);
    }
  }

  addOnLineNumberClickListener(lineIndex, _lineNumView = null) {
    let lineNumView = _lineNumView || this.interview.querySelector(`#row-lineindex-${lineIndex}`);
    lineNumView.addEventListener('click', event => {
      if (event.shiftKey) {
        const minMarkLineIndex = Math.min(...this.currMarkLineIndexes);
        const maxMarkLineIndex = Math.max(...this.currMarkLineIndexes);
        if (lineIndex < minMarkLineIndex) {
          for(let i = lineIndex; i < minMarkLineIndex; i++) {
            this.markLineOfCode(i);
          }
        } else if(lineIndex > maxMarkLineIndex) {
          for(let i = maxMarkLineIndex + 1; i <= lineIndex; i++) {
            this.markLineOfCode(i);
          }
        }
      } else {
        this.resetMarkLinesOfCode();
        this.markLineOfCode(lineIndex);
      }

      this.interview.sync(this.component, {
        actions: [
          { marklines: this.currMarkLineIndexes }
        ]
      });
    });
  }
  
  addEditorRules() {
    this.keyInputHandler.addListener("Input", (e) => {
      switch (this.currentState) {
        case CodeEditor.States.Code:
          let [formattedCode, selection] =
            Formatter.formatBlockEnd(this.lang, e.target.value, e.target.selectionEnd);
          return [formattedCode, selection, selection];
        case CodeEditor.States.Cmd:
          this.codeInput.value = this.codeInput.value.slice(0, -1);
          if (e.data) {
            this.commandLine.textContent += e.data;
          }
          break;
      }
    });

    this.keyInputHandler.addListener("Enter", (e) => {
      switch (this.currentState) {
        case CodeEditor.States.Code:
          let [formattedCode, selection] =
            Formatter.formatBlockBegin(this.lang, e.target.value, e.target.selectionEnd);
          return [formattedCode, selection, selection];		
        case CodeEditor.States.Cmd:
          this.commander.exec(this.commandLine.textContent);
          this.commandLine.style.visibility = "hidden";
          this.commandLine.textContent = ":";
          this.focusCoding();
          break;
        default:
          break;
      }
    });

		this.keyInputHandler.addListener("Escape", (e) => {
      switch (this.currentState) {
        case CodeEditor.States.Code:
          // release lock
          this.interview.sync(this.component, {
            lockTime: Date.now()  
          })
          break;
        case CodeEditor.States.Cmd:
          this.commandLine.style.visibility = "hidden";
          this.commandLine.textContent = ":";
          this.focusCoding();
          break;
        default:
          break;
      }
		});

    this.keyInputHandler.addListener("Tab", (e) => {
      return Formatter.moveLinesRight(e.target.value, e.target.selectionStart, e.target.selectionEnd);
    });

    this.keyInputHandler.addListener("ShiftTab", (e) => {
      return Formatter.moveLinesLeft(e.target.value, e.target.selectionStart, e.target.selectionEnd);
    });

    this.keyInputHandler.addListener("MoveLinesUp", (e) => {
      return Formatter.moveLinesUp(e.target.value, e.target.selectionStart, e.target.selectionEnd);
    });

    this.keyInputHandler.addListener("MoveLinesDown", (e) => {
      return Formatter.moveLinesDown(e.target.value, e.target.selectionStart, e.target.selectionEnd);
    });

    this.keyInputHandler.addListener("DeleteLines", (e) => {
      return Formatter.deleteLines(e.target.value, e.target.selectionStart, e.target.selectionEnd);
    });

    this.keyInputHandler.addListener("CopyPasteLine", (e) => {
      return Formatter.copyPasteLine(e.target.value, e.target.selectionStart);
    });

    this.keyInputHandler.addListener("CommentLines", (e) => {
      return Formatter.commentLines(this.lang, e.target.value, e.target.selectionStart, e.target.selectionEnd);
    });

    this.keyInputHandler.addListener("ForwardCode", (e) => {
      let forwardCode = this.history.forward();
      this.codeInput.value = forwardCode;
      this.highlightCode(forwardCode);
    });

    this.keyInputHandler.addListener("BackwardCode", (e) => {
      let backwardCode = this.history.backward();
      this.codeInput.value = backwardCode;
      this.highlightCode(backwardCode);
    });

    this.keyInputHandler.addListener("InputCommand", (e) => {
      this.currentState = CodeEditor.States.Cmd;
      this.codeInput.classList.remove(`${this.theme.name}-caret`);
      this.codeInput.classList.add("caret-transparent");
      this.commandLine.style.visibility = "visible";
      this.commandLine.focus();
    });

    document.addEventListener("selectionchange", event => {
      let activeElement = document.activeElement;
      if (activeElement && activeElement == this.codeInput) {
        let selectStart = this.codeInput.selectionStart;
        let numLine = this.countNumOfLines(0, selectStart);
        this.highlightLineOfCode(numLine);
      }
    });
  }
}
