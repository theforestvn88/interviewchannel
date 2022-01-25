import { HighlightJS } from "highlight.js";
import { LineNumbers } from "./highlightjs-line-numbers";

export function highlightCode(element) {
  element.querySelectorAll("pre").forEach(function(preElement) {
    const languageRegex = /(?!lang\-\\w\*)lang-\w*\W*/gm;
    const codeElement = document.createElement("code");

    let preElementTextNode = preElement.removeChild(preElement.firstChild);
    let languages = preElementTextNode.textContent.match(languageRegex);

    if (languages) {
      let language = languages[0].toString().trim();
      preElementTextNode.textContent = preElementTextNode.textContent.replace(
        language,
        ""
      );
      codeElement.classList.add(language, "line-numbers");

      codeElement.append(preElementTextNode);
      preElement.append(codeElement);

      window.hljs = HighlightJS;
      const lineNumber = LineNumbers(window, document);
      // HighlightJS.initLineNumbersOnLoad();

      HighlightJS.highlightElement(codeElement, language.split("-")[1]);
      // HighlightJS.lineNumbersBlock(codeElement);
    }
  });
}
