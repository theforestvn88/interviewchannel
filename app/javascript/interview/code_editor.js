import * as Formatter from "formatter";
import { InteractionStates, KeyInputHandler, Commander } from "./interaction";
import History from "./history";
import Theme from "./theme";
import { CodeFileManagement, CodeFile } from "./file";

export default class CodeEditor {
  static SLOGAN = "in code we trust !!!";
  static InitNumOfLines = 10;
	static LOCKTIME = 3000; // 3s
  static ModifyCodeEvents = [
	  "InputCode",
    "DeleteCodeChar", 
	  "BreakLineCode",
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
    this.commander = new Commander(this);

    this.codeFileName = this.interview.querySelector("#code-filename");
    this.codeInput = this.interview.querySelector(".code-input");
    this.codeEditor = this.interview.querySelector(".code-editor");
    this.codeHighlight = this.interview.querySelector(".code-hl");
    this.commandLine = this.interview.querySelector("#editor-command");
    this.lockView = this.interview.querySelector("#editor-lock");
    this.resultView = this.interview.querySelector("#editor-result");

    // files
    this.fileManagement = new CodeFileManagement(`interview-${this.interview.getAttribute("interview-id")}`);
    this.loadSession();

    this.keyInputHandler = new KeyInputHandler(this.codeInput);
		// after modifying code callbacks  
    this.keyInputHandler.after(CodeEditor.ModifyCodeEvents, ([formattedCode, selectionStart, selectionEnd]) => {
      this.setCode(formattedCode);
      this.codeInput.setSelectionRange(selectionStart, selectionEnd);
    });
		// decorating editor callbacks
		this.keyInputHandler.after(CodeEditor.DecoratingEvents, ([formattedCode, s, e]) => {
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
        file: {
          path: this.currentFile.path,
          code: formattedCode,
          selection: [this.codeInput.selectionStart, this.codeInput.selectionEnd]
        }
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

    ["main", "header", "command", "intro", "codeline-hl", "codeline-marked", "numline", "result", "lock"].forEach(part => {
      let oldCssClass = `${oldTheme.name}-${part}`;
      let newCssClass = `${newTheme.name}-${part}`;
      for (let element of document.querySelectorAll(`.${oldCssClass}`)) {
        element.classList.remove(oldCssClass);
        element.classList.add(newCssClass);
      }
    });

    this.codeInput.classList.remove(`${oldTheme.name}-caret`);
    this.codeInput.classList.add(`${newTheme.name}-caret`);
    this.interview.querySelector("#editor-theme").textContent = `@${theme}`;
  }

  switchHighlightTheme() {
    for (let link of document.querySelectorAll(".codestyle")) {
      link.disabled = !link.href.match(this.theme.config.highlight + "\\.min.css$");
    }
  }

  receive(data) {
    if (data.user_id != this.interview.user_id) {
      if (data.lock) { // other takes lock
        this.lockTime = Date.now() + CodeEditor.LOCKTIME;
        this.setLock(`${data.lock} is coding`, CodeEditor.LOCKTIME);
      }

      if (data.file) {
        if (data.file.path && data.file.path !== this.currentFile.path) {
          this.setLock(`${data.user_id} open ${data.file.path}`, CodeEditor.LOCKTIME);
          this.syncFile(data.file.path, data.file.code);
        } else {
          if (data.file.code) {
            this.setCode(data.file.code);
            this.saveCurrentFile(data.file.code);
          }

          if (data.file.selection) {
            this.codeSelection = data.file.selection;
            this.codeInput.setSelectionRange(...this.codeSelection);
          }

          if (data.file.marklines) {
            this.showMarklines(data.marklines);
          }
        }

        this.keyInputHandler.syncState(InteractionStates.Code);
      }

      if (data.command) {
        this.setLock(`${data.user_id} ${data.command}`, 2000*60);
        this.keyInputHandler.syncState(InteractionStates.Cmd);
      }

      if (data.result) {
        this.runningCodeLock = null;
        this.showResult(data.result);
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
    this.resultView.textContent = "";
    this.resultView.style.visibility = "hidden";
    this.commandLine.style.visibility = "hidden";
    this.commandLine.textContent = ":";

    this.codeInput.classList.remove("caret-transparent");
    this.codeInput.classList.add(`${this.currentTheme.name}-caret`);
    this.codeInput.focus();
  }

  focusCommand() {
    this.codeInput.classList.remove(`${this.theme.name}-caret`);
    this.codeInput.classList.add("caret-transparent");
    this.commandLine.style.visibility = "visible";
    this.commandLine.focus();
  }

  setCode(code) {
    this.codeInput.value = code;
    this.updateSologan();
    this.highlightCode(code);
    this.updateCodeOverlay();
    this.history.push(code);
  }

  revertInputCode() {
    this.codeInput.value = this.history.applyVersion(this.history.currentVersion);
    if (this.codeSelection) this.codeInput.setSelectionRange(...this.codeSelection);
  }

  breakLineCode() {
    let start = this.codeInput.selectionStart;
    let end = this.codeInput.selectionEnd;
    this.codeInput.value = this.codeInput.value.substring(0, start) + "\n" + this.codeInput.value.substring(end);
    start++;
    this.codeInput.setSelectionRange(start, start);
  }

  inputCode(key) {
    let blockBegin = false;

    switch (key) {
      case "deleteContentBackward":
        break;
      case "insertLineBreak":
        blockBegin = true;
        break;
      default:
        break;
    }

    let [formattedCode, selection] = Formatter.format(this.lang, this.codeInput.value, this.codeInput.selectionEnd, blockBegin);
    this.saveCurrentFile(formattedCode);

    return [formattedCode, selection, selection];
  }

  inputCommand(keyCode) {
    switch (keyCode) {
      case "Backspace":
        this.commandLine.textContent = this.commandLine.textContent.slice(0, -1);
        break;

      default:
        this.commandLine.textContent += keyCode;
        this.revertInputCode();
        break;
    }
  }

  highlightCode(code = null) {
    if (code !== null) {
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

  showMarklines(marklines) {
    this.resetMarkLinesOfCode();
    for(let i of marklines) {
			this.markLineOfCode(i);
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
        file: {
          marklines: this.currMarkLineIndexes
        }
      });
    });
  }
  
  addEditorRules() {
    this.keyInputHandler.addListener("InputCode", (key) => {
      return this.inputCode(key);
    });

    this.keyInputHandler.addListener("OpenCommand", (e) => {
      this.codeSelection = [this.codeInput.selectionStart, this.codeInput.selectionEnd];
      this.focusCommand();
    });

    this.keyInputHandler.addListener("InputCommand", (key) => {
      this.inputCommand(key);
    });

    this.keyInputHandler.addListener("SearchFile", (key) => {
      this.inputCommand(key);
      this.searchFile(this.commandLine.textContent.slice(1));
    });

    this.keyInputHandler.addListener("BreakLineCode", (e) => {
      return this.inputCode("Enter");
    });

    this.keyInputHandler.addListener("LoadSelectedFile", (e) => {
      this.loadFile(this.selectedFile);
      this.focusCoding();
    });

    this.keyInputHandler.addListener("ExecCommand", (e) => {
      this.commander.exec(this.commandLine.textContent);
    });
 
    this.keyInputHandler.addListener("DeleteCodeChar", (e) => {
      return this.inputCode("Backspace");
    });

    this.keyInputHandler.addListener("DeleteSearchChar", (e) => {
      this.inputCommand("Backspace");
      this.searchFile(this.commandLine.textContent.slice(1));
    });

    this.keyInputHandler.addListener("DeleteCommandChar", (e) => {
      this.inputCommand("Backspace");
    });

		this.keyInputHandler.addListener("ReleaseLock", (e) => {
      // TODO: do we need manual release lock ?
		});
    
    this.keyInputHandler.addListener("FocusCoding", (e) => {
      this.focusCoding();
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

    this.keyInputHandler.addListener("SelectAboveFile", (e) => {
      this.willSelectFile(this.selectedFileIndex - 1);
    });

    this.keyInputHandler.addListener("MoveLinesDown", (e) => {
      return Formatter.moveLinesDown(e.target.value, e.target.selectionStart, e.target.selectionEnd);
    });

    this.keyInputHandler.addListener("SelectBelowFile", (e) => {
      this.willSelectFile(this.selectedFileIndex + 1);
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

    this.keyInputHandler.addListener("OpenSearchFile", (e) => {
      this.codeSelection = [this.codeInput.selectionStart, this.codeInput.selectionEnd];
      this.resultView.style.visibility = "visible";
      this.searchFile("");
      this.focusCommand();
    });

    document.addEventListener("selectionchange", event => {
      let activeElement = document.activeElement;
      if (activeElement && activeElement == this.codeInput) {
        this.interview.sync(this.component, {
          file: {
            path: this.currentFile.path,
            selection: [this.codeInput.selectionStart, this.codeInput.selectionEnd]
          }
        })
      }
    });
  }

  loadSession() {
    this.currentFile = this.fileManagement.loadSession();
    if (!this.currentFile) {
      this.currentFile = this.fileManagement.createCodeFile("we_code.rb");
    }

    this.openFile(this.currentFile);
  }

  createFile(filePath) {
    this.currentFile = this.fileManagement.createCodeFile(filePath);
    this.openFile(this.currentFile);
  }

  loadFile(filePath) {
    this.currentFile = this.fileManagement.loadCodeFile(filePath);
    this.openFile(this.currentFile);
  } 

  openFile(file) {
    this.currentFile = file;
    this.selectedFile = this.currentFile.path;
    this.lang = this.currentFile.lang;
    this.codeFileName.textContent = `>> interview >> ./${this.currentFile.path}`;
    this.history.reset();
    this.setCode(this.currentFile.content);

    this.interview.sync(this.component, {
      file: {
        path: this.currentFile.path,
        code: this.currentFile.content
      }
    });
  }

  static SearchPageSize = 7;
  searchFile(searchKey) {
    this.searchFilePaths = this.fileManagement.searchCodeFile(searchKey);
    let currentFileIndex = Math.max(0, this.searchFilePaths.indexOf(this.currentFile.path));
    this.selectedFileIndex = currentFileIndex;
    this.selectedFile = this.searchFilePaths[currentFileIndex];
    let offset = Math.max(0, currentFileIndex - CodeEditor.SearchPageSize + 1);
    this.showResultSearch(offset);
  }

  syncFile(path, code = "") {
    this.currentFile = this.fileManagement.loadCodeFile(path);
    if (!this.currentFile) {
      this.currentFile = this.fileManagement.createCodeFile(path);
    }

    this.saveCurrentFile(code);
    this.openFile(this.currentFile);
  }

  saveCurrentFile(code) {
    this.currentFile.content = code;
    this.fileManagement.saveCodeFile(this.currentFile);
  }

  showResultSearch(pageStart = 0, pageSize = CodeEditor.SearchPageSize) {
    this.resultPageStart = pageStart;
    this.resultPageEnd = Math.min(this.searchFilePaths.length, pageStart + pageSize);
    this.resultView.value = "";
    this.searchFilePaths.slice(this.resultPageStart, this.resultPageEnd).forEach(f => {
      this.resultView.value += f === this.selectedFile ? `* ${f}\n` : `> ${f}\n`;
    });
  }

  willSelectFile(index) {
    this.selectedFileIndex = index < 0 ? 0 : Math.min(index, this.searchFilePaths.length - 1);
    this.selectedFile = this.searchFilePaths[this.selectedFileIndex];

    if (this.selectedFileIndex < this.resultPageStart) {
      this.showResultSearch(this.selectedFileIndex);
    } else if (this.selectedFileIndex >= this.resultPageEnd) {
      this.showResultSearch(this.resultPageStart + (this.resultPageEnd - this.selectedFileIndex + 1));
    } else {
      this.showResultSearch(this.resultPageStart);
    }
  }

  run(params) {
    if (!this.runningCodeLock) {
      let [lineStart, lineEnd] = params;
      let [start, end] = [0, -1];
      if (!lineStart && !lineEnd) {
        if (this.codeSelection[0] !== this.codeSelection[1]) {
          [start, end] = this.codeSelection;
        }
      } else {
        let lines = this.codeInput.value.split("\n");
        start = lines.slice(0, Math.max(lineStart - 1, 0)).join("\n").length;
        end = lines.slice(0, lineEnd).join("\n").length;
      }
      
      const startTime = Date.now();
      this.runningCodeLock = startTime;
      // send command to server
      // get result from server at the onReceive method
      this.interview.sync(this.component, {
        command: `run ${this.currentFile.path} ${start} ${end}`
      }) 
      // timeout in 2 minutes
      setTimeout(() => {
        if (this.runningCodeLock == startTime) {
          this.showResult("time out");
          this.runningCodeLock = null;
          this.interview.sync(this.component, {
            result: "time out"
          })
        }
      }, 2000*60);
    }
  }

  showResult(result) {
    this.resultView.style.visibility = "visible";
    this.resultView.value = result;
  }

  setLock(lockName, expiredTime) {
    let lock = {
      name: lockName,
      progress: 0
    };
    this.lock = lock;
    this.showLock(lock);
    setTimeout(() => {
      if (this.lock === lock) this.releaseLock();
    }, expiredTime);
  }

  releaseLock() {
    this.hideLock();
    this.lock = null;
  }

  showLock(lock) {
    if (this.lock === lock) {
      this.lockView.style.visibility = "visible";
      this.lockView.textContent = `${lock.name} ` + `${"......".substring(lock.progress)}`;
      lock.progress = (lock.progress + 1) % 6;      
      setTimeout(() => {
        this.showLock(lock);     
      }, 500);
    }
  }

  hideLock() {
    this.lockView.style.visibility = "hidden";
  }
}
