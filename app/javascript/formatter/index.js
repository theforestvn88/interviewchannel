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
  let indentTabs = countIndent.startBlock(lang, lastLine);
  
  if (indentTabs <= 0)
    return [formattedCode, selection];

  if (codeBlock.isBlockBegin(lang, lastLine)) {
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
  } else {
    [formattedCode, selection] = addTabs(code, position, indentTabs - 1);
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

function moveLinesUp(code, selectionStart, selectionEnd) {
  let anchorPointStart = 
    code.charAt(selectionStart) == "\n" ? selectionStart - 1 : selectionStart;
  let aboveLineEnd = code.lastIndexOf("\n", anchorPointStart);
  if (aboveLineEnd <= 0) {
    return [code, selectionStart];
  }

  let aboveLineStart = code.lastIndexOf("\n", aboveLineEnd - 1);
  let moveLineEnd = code.indexOf("\n", selectionEnd - 1);

  let formattedCode =
    code.substring(0, aboveLineStart) +
    code.substring(aboveLineEnd, moveLineEnd) +
    code.substring(aboveLineStart, aboveLineEnd) +
    code.substring(moveLineEnd);

  return [formattedCode, aboveLineStart + selectionStart - aboveLineEnd];
}

function moveLinesDown(code, selectionStart, selectionEnd) {
  let belowLineStart = code.indexOf("\n", selectionEnd);
  if (belowLineStart <= 0) {
    return [code, selectionStart];
  }

  let belowLineEnd = code.indexOf("\n", belowLineStart + 1);
  let moveLineStart = code.lastIndexOf("\n", selectionStart - 1);

  let formattedCode =
    code.substring(0, moveLineStart) +
    code.substring(belowLineStart, belowLineEnd) +
    code.substring(moveLineStart, belowLineStart) +
    code.substring(belowLineEnd);

  return [formattedCode, (belowLineEnd - belowLineStart) + selectionStart];
}

function moveLinesLeft(code, selectionStart, selectionEnd) {
  let anchorPos = code.lastIndexOf("\n", selectionStart);
  let anchorEndPos = selectionEnd;
  let formattedCode = code;
  while (anchorPos < anchorEndPos) {
    let lineStart = anchorPos + 1;
    if (formattedCode.charAt(lineStart) == "\t") {
      formattedCode =
        formattedCode.substring(0, lineStart) +
        formattedCode.substring(lineStart + 1);
    }
    
    anchorPos = formattedCode.indexOf("\n", lineStart);
    anchorEndPos -= 1;
  }

  return [formattedCode, selectionStart - 1];
}

function moveLinesRight(code, selectionStart, selectionEnd) {
  let anchorPos = code.lastIndexOf("\n", selectionStart - 1);
  let anchorEndPos = selectionEnd;
  let formattedCode = code;

  while (anchorPos > -1 && anchorPos < anchorEndPos) {
    formattedCode =
      formattedCode.substring(0, anchorPos + 1) +
      "\t" +
      formattedCode.substring(anchorPos + 1);
    
    anchorPos = formattedCode.indexOf("\n", anchorPos + 1);
    anchorEndPos += 1;
  }

  return [formattedCode, selectionStart + 1];
}

function commentLines(lang, code, selectionStart, selectionEnd) {
  let prefix = CommentPrefix[lang] || CommentPrefix["default"];
  let anchorPos = code.lastIndexOf("\n", selectionStart - 1);
  let anchorEndPos = selectionEnd;
  let formattedCode = code;
  let selection;
  
  while (anchorPos > -1 && anchorPos < anchorEndPos) {
    let lineStart = anchorPos + 1;
    if (formattedCode.charAt(lineStart) == prefix) { // uncomment
      let cutPos = formattedCode.charAt(lineStart + 1) == " " ? lineStart + 2 : lineStart + 1;
      formattedCode =
        formattedCode.substring(0, lineStart) +
        formattedCode.substring(cutPos);
      if (!selection) selection = selectionStart - (cutPos - lineStart);
      anchorEndPos -= cutPos - lineStart;
    } else { // comment
      formattedCode =
        formattedCode.substring(0, lineStart) +
        prefix + " " +
        formattedCode.substring(lineStart);
      if (!selection) selection = selectionStart + 2;
      anchorEndPos += 1;
    }
    anchorPos = formattedCode.indexOf("\n", lineStart);
  }

  return [formattedCode, selection];
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
  commentLines,
  formatBlockBegin,
  formatBlockEnd,
  moveLinesUp,
  moveLinesDown,
  moveLinesLeft,
  moveLinesRight
};
