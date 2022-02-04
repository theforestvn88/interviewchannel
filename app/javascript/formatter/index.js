import { HighlightJS } from "highlight.js";
window.hljs = HighlightJS;

function highlightCode(element, language) {
  element.querySelectorAll("pre").forEach(function(preElement) {
    const codeElement = document.createElement("code");
    let preElementTextNode = preElement.removeChild(preElement.firstChild);

    codeElement.classList.add(language);
    codeElement.append(preElementTextNode);
    preElement.append(codeElement);

    HighlightJS.highlightElement(codeElement, language);
  });
}

import { CommentPrefix } from "./languages.js";
function commentOut(lang, str) {
  let prefix = CommentPrefix[lang] || CommentPrefix["default"];
  return `${prefix} ${str}`;
}

import countIndent from "./indent.js";

export { highlightCode, countIndent, commentOut };
