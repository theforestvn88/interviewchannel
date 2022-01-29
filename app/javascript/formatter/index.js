import { HighlightJS } from "highlight.js";
window.hljs = HighlightJS;

export function highlightCode(element, language) {
  element.querySelectorAll("pre").forEach(function(preElement) {
    const codeElement = document.createElement("code");
    let preElementTextNode = preElement.removeChild(preElement.firstChild);

    codeElement.classList.add(language);
    codeElement.append(preElementTextNode);
    preElement.append(codeElement);

    HighlightJS.highlightElement(codeElement, language);
  });
}
