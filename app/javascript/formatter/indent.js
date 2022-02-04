import { BeginBlockSymbols, EndBlockSymbols } from "./languages"

// return the #tabs needed
function countIndent() {
  const beginBlockPrefixRegex = function(lang) {
    let prefix = (BeginBlockSymbols[lang] || BeginBlockSymbols["default"]).prefix;
    if (prefix) {
      return new RegExp(`\\t*${prefix}`);
    }
  }

  const beginBlockSuffixRegex = function(lang) {
    let suffix = (BeginBlockSymbols[lang] || BeginBlockSymbols["default"]).suffix;
    if (suffix) {
      return new RegExp(suffix);
    }
  }

  const endBlockRegex = function(lang) {
    if (EndBlockSymbols.hasOwnProperty(lang)) {
      let endSymbols = EndBlockSymbols[lang];
      if (endSymbols) {
        return new RegExp(`\\t+${endSymbols}$`);
      }
    } else {
      return new RegExp(`\\t+${EndBlockSymbols["default"]}$`);
    }
  }

  const startBlock = function(lang, lineOfCode) {
    let numOfTabs = (lineOfCode.match(/\t/g) || []).length;
    let prefixBeginBlockRegex = beginBlockPrefixRegex(lang);
    let suffixBeginBlockRegex = beginBlockSuffixRegex(lang);
    
    if (lineOfCode.match(prefixBeginBlockRegex) || lineOfCode.match(suffixBeginBlockRegex)) {
      return numOfTabs + 1;
    }

    return numOfTabs;
  }

  const endBlock = function(lang, lineOfCode) {
    let endIndentRegex = new RegExp(`\\t+${EndBlockSymbols[lang]}$`);
    if (lineOfCode.match(endIndentRegex)) {
      return -1;
    }

    return 0;
  }

  return {
    startBlock,
    endBlock
  }
}

export default countIndent();