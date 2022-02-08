import countIndent from "./indent.js";
import codeBlock from "./code_block.js";
import { CommentPrefix } from "./languages.js";
import { HighlightJS } from "highlight.js";

window.hljs = HighlightJS;
function highlightCodeElement(element, language) {
  element.querySelectorAll("pre").forEach(function(preElement) {
    const codeElement = document.createElement("code");
    let preElementTextNode = preElement.removeChild(preElement.firstChild);

    codeElement.classList.add(language);
    codeElement.append(preElementTextNode);
    preElement.append(codeElement);

    HighlightJS.highlightElement(codeElement, language);
  });
}

// return [formatted code, selection position]
function addTabs(code, position, numOfTabs) {
  let formattedCode =
    code.substring(0, position) +
    "\t".repeat(numOfTabs) +
    code.substring(position);

  return [formattedCode, position + numOfTabs];
}

function removeTabs(code, position, numOfTabs) {
  let lastTabIndex = code.lastIndexOf("\t", position);
  let removePosition = lastTabIndex - numOfTabs + 1;
  let formattedCode = code.substring(0, removePosition) + code.substring(lastTabIndex + 1);

  return [formattedCode, position - numOfTabs];
}

function lastLineofCode(lang, code, position) {
  let lineStart = Math.max(code.lastIndexOf("\n", position - 2), 0);
  let lineEnd = position;

  return [code.substring(lineStart, lineEnd), lineStart, lineEnd];
}

function formatBlockBegin(lang, code, position) {
  let [formattedCode, selection] = [code, position];
  let [lastLine, lastLineStart, lastLineEnd] = lastLineofCode(lang, code, position);
  let indentTabs = 0;

  if (codeBlock.isBlockBegin(lang, lastLine)) {
    indentTabs = countIndent.startBlock(lang, lastLine);
    if (indentTabs > 0) {
      [formattedCode, selection] = addTabs(code, position, indentTabs);

      // case middle {}
      const pointerIndex = position + indentTabs;
      if (formattedCode.charAt(pointerIndex) == "}") {
        formattedCode =
          formattedCode.substring(0, pointerIndex) +
          "\n" +
          "\t".repeat(indentTabs - 1) +
          formattedCode.substring(pointerIndex);
        selection = pointerIndex;
      }
    }
  }

  return [formattedCode, selection];
}

function formatBlockEnd(lang, code, position) {
  let [formattedCode, selection] = [code, position];
  let [lastLine, lastLineStart, lastLineEnd] = lastLineofCode(lang, code, position);
  let indentTabs = 0;

  if (codeBlock.isBlockEnd(lang, lastLine)) {
    indentTabs = countIndent.endBlock(lang, lastLine);
    if (indentTabs < 0) {
      [formattedCode, selection] = removeTabs(code, position, -indentTabs);
    }
  }

  return [formattedCode, selection];
}

function moveLineCodeUp(code, position) {
  let anchorPoint = 
    code.charAt(position) == "\n" ? position - 1 : position 
  let aboveLineEnd = code.lastIndexOf("\n", anchorPoint);
  if (aboveLineEnd <= 0) {
    return [code, position];
  }

  let aboveLineStart = code.lastIndexOf("\n", aboveLineEnd - 1);
  let moveLineEnd = code.indexOf("\n", anchorPoint);

  let formattedCode =
    code.substring(0, aboveLineStart) +
    code.substring(aboveLineEnd, moveLineEnd) +
    code.substring(aboveLineStart, aboveLineEnd) +
    code.substring(moveLineEnd);

  return [formattedCode, aboveLineStart + position - aboveLineEnd];
}

function moveLineCodeDown(code, position) {
  let anchorPoint = position;
  let belowLineStart = code.indexOf("\n", anchorPoint);
  if (belowLineStart <= 0) {
    return [code, position];
  }

  let belowLineEnd = code.indexOf("\n", belowLineStart + 1);
  let moveLineStart = code.lastIndexOf("\n", anchorPoint - 1);

  let formattedCode =
    code.substring(0, moveLineStart) +
    code.substring(belowLineStart, belowLineEnd) +
    code.substring(moveLineStart, belowLineStart) +
    code.substring(belowLineEnd);

  return [formattedCode, (belowLineEnd - belowLineStart) + position];
}

function commentOut(lang, str) {
  let prefix = CommentPrefix[lang] || CommentPrefix["default"];
  return `${prefix} ${str}`;
}

export { 
  highlightCodeElement, 
  codeBlock, 
  countIndent, 
  commentOut,
  addTabs,
  removeTabs,
  formatBlockBegin,
  formatBlockEnd,
  moveLineCodeUp,
  moveLineCodeDown
};
