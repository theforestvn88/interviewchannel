import { HighlightJS } from "highlight.js";
import { LineNumbers } from "./highlightjs-line-numbers";

window.hljs = HighlightJS;

export function highlightCode(element, language, withLineNumber = false) {
  element.querySelectorAll("pre").forEach(function(preElement) {
    const codeElement = document.createElement("code");
    let preElementTextNode = preElement.removeChild(preElement.firstChild);

    codeElement.classList.add(language, "line-numbers");
    codeElement.append(preElementTextNode);
    preElement.append(codeElement);

    HighlightJS.highlightElement(codeElement, language);
    if (withLineNumber) {
      LineNumbers(window, document);
      HighlightJS.lineNumbersBlock(codeElement);
    }
  });
}
