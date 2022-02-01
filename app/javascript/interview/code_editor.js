import { highlightCode } from "formatter";

const InitNumOfLines = 10;

export default class CodeEditor {
  constructor(interview) {
    this.interview = interview;
    this.setupEditor();
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

  get style() {
    if (!this.selectedStyle) {
      this.selectedStyle = this.interview.getAttribute("style") || "default";
    }

    return this.selectedStyle;
  }

  set style(_style) {
    this.selectedStyle = _style;
  }

  formatCode() {
    highlightCode(this.codeEditor, this.lang);
  }

  receive(data) {
    if (data.user != this.interview.user) {
      let before = this.countNumOfLines();
      this.codeHighlight.firstChild.textContent = data.code;
      this.codeInput.value = data.code;
      let after = this.countNumOfLines();
      while (after > before && after > InitNumOfLines) {
        before += 1;
        this.addLine(before);
        this.expandHeight();
      }

      this.formatCode();
    }
  }

  setupEditor() {
    let langSelect = this.interview.querySelector("#lang");
    langSelect.addEventListener("change", e => {
      this.lang = e.target.value;
      this.formatCode();
    });

    let styleSelect = this.interview.querySelector("#style");
    styleSelect.addEventListener("change", e => {
      this.style = e.target.value;
      for (let link of document.querySelectorAll(".codestyle")) {
        link.disabled = !link.href.match(this.style + "\\.min.css$");
      }
      this.formatCode();
    });

    this.codeInput = this.interview.querySelector(".input-transparent");
    this.codeEditor = this.interview.querySelector(".code-editor");
    this.codeHighlight = this.interview.querySelector(".code-hl");

    this.codeHighlight.firstChild.textContent = "# in code we trust !!!";
    this.codeInput.value = "# in code we trust !!!";
    this.formatCode();

    this.codeInput.addEventListener("input", e => {
      let codeText = e.target.value;
      this.interview.sync({
        component: "code",
        code: codeText,
        id: this.interview.id,
        user: this.interview.user
      });
      this.codeHighlight.firstChild.textContent = codeText;
      this.formatCode();
    });

    this.currLineIndex = 2;
    this.currMarkLineIndexes = [];
    this.totalLines = InitNumOfLines;
    for(let i = 1; i <= this.totalLines; i++) {
      this.addOnLineNumberClickListener(i);
    }

    this.addEditorRules();
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

  highlightLineOfCode(lineIndex) {
    if (this.currLineIndex) {
      this.interview
        .querySelector(`#row-${this.currLineIndex}`)
        .classList.remove("current-code-line");
    }

    let curLineView = this.interview.querySelector(`#row-${lineIndex}`);
    if (curLineView) {
      curLineView.classList.add("current-code-line");
      this.currLineIndex = lineIndex;
    }
  }

  resetMarkLinesOfCode() {
    for(let markLineIndex of this.currMarkLineIndexes) {
      this.interview
        .querySelector(`#row-${markLineIndex}`)
        .classList.remove("current-code-line", "bg-red-100");
    }

    this.currMarkLineIndexes = [];
  }

  markLineOfCode(lineIndex) {
    let curLineView = this.interview.querySelector(`#row-${lineIndex}`);
    if (curLineView) {
      curLineView.classList.add("bg-red-100");
      this.currMarkLineIndexes.push(lineIndex);
    }
  }

  expandHeight() {
    this.codeInput.rows = this.totalLines;

    this.codeEditor.style.height = 'auto';
    this.codeEditor.style.height = this.codeEditor.scrollHeight + 'px';

    this.codeHighlight.style.height = 'auto';
    this.codeHighlight.style.height = this.codeHighlight.scrollHeight + 'px';
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
    });
  }
  
  addEditorRules() {
    this.codeInput.addEventListener("keyup", e => {
      switch (e.key) {
        case "Enter":
          e.preventDefault();
          let codeText = this.codeInput.value;
          let numLines = (codeText.match(/\n/g) || []).length + 1;
          if (this.totalLines < numLines) {
            this.addLine(numLines);
            this.totalLines = numLines;
            if (this.currLineIndex == this.totalLines - 1) {
              this.highlightLineOfCode(this.totalLines);
              this.currLineIndex = this.totalLines;
            }
            this.expandHeight();
          }
          break;

        default:
          break;
      }
    });

    this.codeInput.addEventListener("keydown", e => {
      switch (e.key) {
        case "Tab":
          e.preventDefault();
          var start = e.target.selectionStart;
          var end = e.target.selectionEnd;
          // set textarea value to: text before caret + tab + text after caret
          e.target.value =
            e.target.value.substring(0, start) +
            "\t" +
            e.target.value.substring(end);
          // put caret at right position again
          e.target.selectionStart = e.target.selectionEnd = start + 1;
          break;

        default:
          break;
      }
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
