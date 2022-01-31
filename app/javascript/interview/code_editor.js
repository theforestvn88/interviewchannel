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
        this.addLines(before);
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

    this.totalLines = InitNumOfLines;
    this.addEditorRules();
  }

  addLines(numLine) {
    let codeOverlay = this.interview.querySelector(".code-editor-overlay");
    let lineView = document.createElement("div");
    lineView.id = `row-${numLine}`;
    lineView.classList.add("code-line");
    let numView = document.createElement("div");
    numView.classList.add("w-6", "flex", "justify-end");

    let numLabel = document.createElement("label");
    numLabel.classList.add("text-xs");
    numLabel.textContent = `${numLine}`;
    let sepLabel = document.createElement("label");
    sepLabel.textContent = "|";
    numView.appendChild(numLabel);
    numView.appendChild(sepLabel);

    lineView.appendChild(numView);
    codeOverlay.appendChild(lineView);
  }

  countNumOfLines(from = 0, to = undefined) {
    let codeText = this.codeInput.value;
    return (codeText.substring(from, to).match(/\n/g) || []).length + 1;
  }

  highlightLineOfCode(numLine) {
    if (this.currNumLine) {
      this.interview
        .querySelector(`#row-${this.currNumLine}`)
        .classList.remove("current-code-line");
    }

    let curLineView = this.interview.querySelector(`#row-${numLine}`);
    if (curLineView) {
      curLineView.classList.add("current-code-line");
      this.currNumLine = numLine;
    }
  }

  expandHeight() {
    this.codeInput.rows = this.totalLines;

    this.codeEditor.style.height = 'auto';
    this.codeEditor.style.height = this.codeEditor.scrollHeight + 'px';

    this.codeHighlight.style.height = 'auto';
    this.codeHighlight.style.height = this.codeHighlight.scrollHeight + 'px';
  }
  
  addEditorRules() {
    this.codeInput.addEventListener("keyup", e => {
      switch (e.key) {
        case "Enter":
          e.preventDefault();
          let codeText = this.codeInput.value;
          let numLines = (codeText.match(/\n/g) || []).length + 1;
          if (this.totalLines < numLines) {
            this.addLines(numLines);
            this.totalLines = numLines;
            if (this.currNumLine == this.totalLines - 1) {
              this.highlightLineOfCode(this.totalLines);
              this.currNumLine = this.totalLines;
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

    document.addEventListener("selectionchange", () => {
      let activeElement = document.activeElement;
      if (activeElement && activeElement == this.codeInput) {
        let selectStart = this.codeInput.selectionStart;
        let numLine = this.countNumOfLines(0, selectStart);
        this.highlightLineOfCode(numLine);
      }
    });
  }
}
