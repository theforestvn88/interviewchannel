import { BeginBlockSymbols, EndBlockSymbols } from "./languages"

function codeBlock(params) {
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

  const isBlockBegin = function(lang, lineOfCode) {
    let prefixBeginBlockRegex = beginBlockPrefixRegex(lang);
    let suffixBeginBlockRegex = beginBlockSuffixRegex(lang);
    
    return (lineOfCode.match(prefixBeginBlockRegex) || lineOfCode.match(suffixBeginBlockRegex));
  }

  const isBlockEnd = function(lang, lineOfCode) {
    let endIndentRegex = endBlockRegex(lang);
    return lineOfCode.match(endIndentRegex);
  }

  return {
    isBlockBegin,
    isBlockEnd
  }
}

export default codeBlock();