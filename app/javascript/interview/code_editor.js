import * as Formatter from "formatter";
import { KeyInputHandler } from "./interaction";

const SLOGAN = "in code we trust !!!";
const InitNumOfLines = 10;
const ItemSelectedBg = "bg-gray-300";

export default class CodeEditor {
  constructor(interview, component) {
    this.interview = interview;
    this.component = component;

    this.codeInput = this.interview.querySelector(".code-input");
    this.codeEditor = this.interview.querySelector(".code-editor");
    this.codeHighlight = this.interview.querySelector(".code-hl");

    this.keyInputHandler = new KeyInputHandler(this.codeInput);
    this.keyInputHandler.after(
      ["Tab", "ShiftTab", "MoveLinesUp", "MoveLinesDown", "CommentLines"], 
      ([formattedCode, selectionStart, selectionEnd]) => {
        this.codeInput.value = formattedCode;
        this.codeInput.setSelectionRange(selectionStart, selectionEnd);
        this.highlightCode(formattedCode);
      }
    );

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
        this.codeInput.value = data.code;
        this.highlightCode(data.code);
        this.updateCodeOverlay(data);
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
        this.highlightCode();
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
        this.highlightCode();
      })
    }

    selectedStyle.textContent = `${prefixStyle}${this.style}`;
    this.interview.querySelector(`#style-${this.style}`)
          .classList.add(ItemSelectedBg);

    this.updateSologan();
    this.highlightCode();

    this.currLineIndex = 2;
    this.currMarkLineIndexes = [];
    this.totalLines = InitNumOfLines;
    for(let i = 1; i <= this.totalLines; i++) {
      this.addOnLineNumberClickListener(i);
    }

    this.addEditorRules();
  }

  highlightCode(code = null) {
    if (code) {
      this.codeHighlight.firstChild.textContent = code;
    }
    Formatter.highlightCodeElement(this.codeEditor, this.lang);
  }

  updateSologan() {
    if (!this.codeInput.value) {
      const sologan = Formatter.commentOut(this.lang, `${SLOGAN}\n`);
      this.codeHighlight.firstChild.textContent = sologan;
      this.codeInput.value = sologan;
    } else {
      if (this.codeInput.value.match(SLOGAN)) {
        let firstNewLineIndex = this.codeInput.value.indexOf("\n");
        this.codeInput.value = 
          Formatter.commentOut(this.lang, SLOGAN) +
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
  
  addEditorRules() {
    this.keyInputHandler.addListener("Common", (e) => {
      var [formattedCode, selection] =
        Formatter.formatBlockEnd(this.lang, e.target.value, e.target.selectionEnd);
      this.codeInput.value = formattedCode;
      this.codeInput.selectionStart = this.codeInput.selectionEnd = selection;

      this.interview.sync(this.component, {
        code: formattedCode,
      });

      this.highlightCode(formattedCode);
    });

    this.keyInputHandler.addListener("Enter", (e) => {
      let [formattedCode, selection] =
        Formatter.formatBlockBegin(this.lang, e.target.value, e.target.selectionEnd);
      this.codeInput.value = formattedCode;
      this.codeInput.selectionStart = this.codeInput.selectionEnd = selection;

      this.highlightCode(formattedCode);
      this.updateCodeOverlay();

      if (this.currLineIndex == this.totalLines - 1) {
        this.highlightLineOfCode(this.totalLines);
        this.currLineIndex = this.totalLines;
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

    this.keyInputHandler.addListener("CommentLines", (e) => {
      return Formatter.commentLines(this.lang, e.target.value, e.target.selectionStart, e.target.selectionEnd);
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
