import { highlightCode } from "formatter";

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

  formatCode(withLineNumber = false) {
    highlightCode(this.codeEditor, this.lang, withLineNumber);
  }

  receive(data) {
    if (data.user != this.interview.user) {
      this.codeHighlight.firstChild.textContent = data.code;
      this.formatCode(true);
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

    this.codeInput = this.interview.querySelector("textarea");
    this.codeEditor = this.interview.querySelector(".code-editor");
    this.codeHighlight = this.interview.querySelector(".code-hl");

    this.codeInput.value = this.codeHighlight.firstChild.textContent;
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

    this.addEditorRules();
  }
}
