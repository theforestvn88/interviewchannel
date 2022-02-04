import { highlightCode, countIndent, commentOut } from "formatter";

const SLOGAN = "in code we trust !!!";
const InitNumOfLines = 10;
const ItemSelectedBg = "bg-gray-300";

export default class CodeEditor {
  constructor(interview, component) {
    this.interview = interview;
    this.component = component;
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

  receive(data) {
    if (data.user != this.interview.user) {
      if (data.code) {
        this.codeHighlight.firstChild.textContent = data.code;
        this.codeInput.value = data.code;
        this.updateCodeOverlay(data);
        this.formatCode();
      }

      if (data.feedback) {
        this.showFeedback(data.feedback);
      }
    }
  }

  setupEditor() {
    const selectedLang = this.interview.querySelector("#selected-lang");
    const prefixLang = selectedLang.getAttribute("prefix");
    const langOptions = this.interview.querySelectorAll("li.lang-option");
    for(let langOpt of langOptions) {
      langOpt.addEventListener("click", e => {
        this.interview.querySelector(`#lang-${this.lang}`)
          .classList.remove(ItemSelectedBg);
        this.lang = e.target.textContent;
        selectedLang.textContent = `${prefixLang}${this.lang}`;
        e.target.classList.add(ItemSelectedBg);

        this.updateSologan();
        this.formatCode();
      })
    }

    selectedLang.textContent = `${prefixLang}${this.lang}`;
    this.interview.querySelector(`#lang-${this.lang}`)
          .classList.add(ItemSelectedBg);

    const selectedStyle = this.interview.querySelector("#selected-style");
    const prefixStyle = selectedStyle.getAttribute("prefix");
    const styleOptions = this.interview.querySelectorAll("li.style-option");
    for(let styleOpt of styleOptions) {
      styleOpt.addEventListener("click", e => {
        this.interview.querySelector(`#style-${this.style}`)
          .classList.remove(ItemSelectedBg);
        this.style = e.target.textContent;
        selectedStyle.textContent = `${prefixStyle}${this.style}`;
        e.target.classList.add(ItemSelectedBg);

        for (let link of document.querySelectorAll(".codestyle")) {
          link.disabled = !link.href.match(this.style + "\\.min.css$");
        }
        this.formatCode();
      })
    }

    selectedStyle.textContent = `${prefixStyle}${this.style}`;
    this.interview.querySelector(`#style-${this.style}`)
          .classList.add(ItemSelectedBg);

    this.codeInput = this.interview.querySelector(".input-transparent");
    this.codeEditor = this.interview.querySelector(".code-editor");
    this.codeHighlight = this.interview.querySelector(".code-hl");

    this.updateSologan();
    this.formatCode();

    this.currLineIndex = 2;
    this.currMarkLineIndexes = [];
    this.totalLines = InitNumOfLines;
    for(let i = 1; i <= this.totalLines; i++) {
      this.addOnLineNumberClickListener(i);
    }

    this.addEditorRules();
  }

  formatCode() {
    highlightCode(this.codeEditor, this.lang);
  }

  updateSologan() {
    if (!this.codeInput.value) {
      const sologan = commentOut(this.lang, `${SLOGAN}\n`);
      this.codeHighlight.firstChild.textContent = sologan;
      this.codeInput.value = sologan;
    } else {
      if (this.codeInput.value.match(SLOGAN)) {
        let firstNewLineIndex = this.codeInput.value.indexOf("\n");
        this.codeInput.value = 
          commentOut(this.lang, SLOGAN) +
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

  showFeedback(feedback) {
    this.resetMarkLinesOfCode();
    for(let fb of feedback) {
      for(let i of fb.marklines) {
        this.markLineOfCode(i);
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
        feedback: [
          { marklines: this.currMarkLineIndexes }
        ]
      });
    });
  }

  addTabs(start, end, numOfTabs) {
    // set textarea value to: text before caret + tab + text after caret
    this.codeInput.value =
      this.codeInput.value.substring(0, start) +
      "\t".repeat(numOfTabs) +
      this.codeInput.value.substring(end);

    // put caret at right position again
    this.codeInput.selectionStart = this.codeInput.selectionEnd = start + numOfTabs;
  }

  removeTabs(end, numOfTabs) {
    let codeText = this.codeInput.value;
    let lastTabIndex = codeText.substring(0, end).lastIndexOf("\t");
    this.codeInput.value =
      this.codeInput.value.substring(0, lastTabIndex) +
      this.codeInput.value.substring(lastTabIndex + 1);
    this.codeInput.selectionStart = this.codeInput.selectionEnd = end - 1;
  }
  
  addEditorRules() {
    this.codeInput.addEventListener("input", e => {
      var start = e.target.selectionStart;
      var lines = this.codeInput.value.substring(0, start).split("\n");
      var lastLine = lines[lines.length - 1];
      var numOfTabs = countIndent.endBlock(this.lang, lastLine);
      if (numOfTabs < 0) {
        this.removeTabs(start, numOfTabs);
      }

      let codeText = e.target.value;
      this.interview.sync(this.component, {
        code: codeText,
      });
      this.codeHighlight.firstChild.textContent = codeText;
      this.formatCode();
    });

    this.codeInput.addEventListener("keyup", e => {
      switch (e.key) {
        case "Enter":
          e.preventDefault();
          var start = e.target.selectionStart;
          var end = e.target.selectionEnd;
          var lines = this.codeInput.value.substring(0, start - 1).split("\n");
          var aboveLine = lines[lines.length - 1];
          var numOfTabs = countIndent.startBlock(this.lang, aboveLine);
          this.addTabs(start, end, numOfTabs);

          // special case
          const pointerIndex = start + numOfTabs;
          if (this.codeInput.value.charAt(pointerIndex) == "}") {
            this.codeInput.value =
              this.codeInput.value.substring(0, pointerIndex) +
              "\n" +
              "\t".repeat(numOfTabs - 1) +
              this.codeInput.value.substring(pointerIndex);

            this.codeInput.selectionStart = this.codeInput.selectionEnd = pointerIndex;
          }

          this.codeHighlight.firstChild.textContent = this.codeInput.value;
          this.updateCodeOverlay();
          this.formatCode();

          if (this.currLineIndex == this.totalLines - 1) {
            this.highlightLineOfCode(this.totalLines);
            this.currLineIndex = this.totalLines;
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
          this.addTabs(start, end, 1);
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
