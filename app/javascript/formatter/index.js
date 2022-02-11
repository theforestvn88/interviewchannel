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

function trim(code) {
  let lastNewLineIndex = code.lastIndexOf("\n");
  let trimPosition = lastNewLineIndex == code.length - 1 ? lastNewLineIndex : -1;
  while (trimPosition > 0 && code.charAt(trimPosition - 1) == "\n") {
    trimPosition -= 1;
  }

  if (trimPosition > 0) {
    return code.substring(0, trimPosition + 1);
  } else {
    return code;
  }
}

function standardSelection(code, selectionStart, selectionEnd) {
  let fitCode = trim(code);
  fitCode = fitCode + "\n";

  while (fitCode.charAt(selectionEnd - 1) == "\n") {
    selectionEnd -= 1;
  }

  return [fitCode, selectionStart, selectionEnd];
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
  let [fitCode, _, fitEnd] = standardSelection(code, selectionStart, selectionEnd);
  selectionEnd = fitEnd;

  let anchorPointStart = 
    fitCode.charAt(selectionStart) == "\n" ? selectionStart - 1 : selectionStart;
  let aboveLineEnd = fitCode.lastIndexOf("\n", anchorPointStart);
  if (aboveLineEnd <= 0) {
    return [fitCode, selectionStart, selectionEnd];
  }

  let aboveLineStart = fitCode.lastIndexOf("\n", aboveLineEnd - 1);
  let moveLineEnd = fitCode.indexOf("\n", selectionEnd - 1);

  let formattedCode =
    fitCode.substring(0, aboveLineStart + 1) +
    fitCode.substring(aboveLineEnd + 1, moveLineEnd + 1) +
    fitCode.substring(aboveLineStart + 1, aboveLineEnd + 1) +
    fitCode.substring(moveLineEnd + 1);

  let newStartPos = aboveLineStart + selectionStart - aboveLineEnd;
  let newEndPos = newStartPos + (selectionEnd - selectionStart);
  return [formattedCode, newStartPos, newEndPos];
}

function moveLinesDown(code, selectionStart, selectionEnd) {
  let [fitCode, _, fitEnd] = standardSelection(code, selectionStart, selectionEnd);
  selectionEnd = fitEnd;

  let belowLineStart = fitCode.indexOf("\n", selectionEnd);
  if (belowLineStart <= 0) {
    return [fitCode, selectionStart, selectionEnd];
  }

  let belowLineEnd = fitCode.indexOf("\n", belowLineStart + 1);
  let moveLineStart = fitCode.lastIndexOf("\n", selectionStart - 1);

  let formattedCode =
    fitCode.substring(0, moveLineStart + 1) +
    fitCode.substring(belowLineStart + 1, belowLineEnd + 1) +
    fitCode.substring(moveLineStart + 1, belowLineStart + 1) +
    fitCode.substring(belowLineEnd + 1);

  let newStartPos = (belowLineEnd - belowLineStart) + selectionStart;
  let newEndPos = newStartPos + (selectionEnd - selectionStart);
  return [formattedCode, newStartPos, newEndPos];
}

function moveLinesLeft(code, selectionStart, selectionEnd) {
  let [fitCode, _, fitEnd] = standardSelection(code, selectionStart, selectionEnd);
  selectionEnd = fitEnd;

  let anchorPos = fitCode.lastIndexOf("\n", selectionStart);
  let anchorEndPos = selectionEnd;
  let formattedCode = fitCode;
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

  return [formattedCode, selectionStart - 1, anchorEndPos];
}

function moveLinesRight(code, selectionStart, selectionEnd) {
  if (selectionStart == selectionEnd) {
    let [formattedCode, position] = addTabs(code, selectionStart, 1);
    return [formattedCode, position, position];
  }

  let [fitCode, _, fitEnd] = standardSelection(code, selectionStart, selectionEnd);
  selectionEnd = fitEnd;


  let anchorPos = fitCode.lastIndexOf("\n", selectionStart - 1);
  let anchorEndPos = selectionEnd;
  let formattedCode = fitCode;

  while (anchorPos > -1 && anchorPos < anchorEndPos) {
    formattedCode =
      formattedCode.substring(0, anchorPos + 1) +
      "\t" +
      formattedCode.substring(anchorPos + 1);
    
    anchorPos = formattedCode.indexOf("\n", anchorPos + 1);
    anchorEndPos += 1;
  }

  return [formattedCode, selectionStart + 1, anchorEndPos];
}

function deleteLines(code, selectionStart, selectionEnd) {
  let [fitCode, _, fitEnd] = standardSelection(code, selectionStart, selectionEnd);
  selectionEnd = fitEnd;

  let anchorPointStart = 
    fitCode.charAt(selectionStart) == "\n" ? selectionStart - 1 : selectionStart;
  let startLineBegin = fitCode.lastIndexOf("\n", anchorPointStart);
  let endLineEnd = fitCode.indexOf("\n", selectionEnd - 1);

  let formattedCode =
    fitCode.substring(0, startLineBegin) +
    fitCode.substring(endLineEnd);

  return [formattedCode, startLineBegin, startLineBegin];
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

  return [formattedCode, selection, anchorEndPos];
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
  deleteLines,
  formatBlockBegin,
  formatBlockEnd,
  moveLinesUp,
  moveLinesDown,
  moveLinesLeft,
  moveLinesRight
};
