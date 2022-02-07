import { IndentTabs } from "./languages.js"

// return the #tabs needed
function countIndent() {
  const indentTabsOf = function(lang) {
    return IndentTabs[lang] || IndentTabs["default"];
  }

  const startBlock = function(lang, lineOfCode) {
    let numOfTabs = (lineOfCode.match(/\t/g) || []).length;
    return numOfTabs + indentTabsOf(lang)["block"];
  }

  const endBlock = function(lang, lineOfCode) {
    return -indentTabsOf(lang)["block"];
  }

  return {
    startBlock,
    endBlock
  }
}

export default countIndent();