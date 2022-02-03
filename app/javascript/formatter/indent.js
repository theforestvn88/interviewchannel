const BeginBlockSymbols = {
  "ruby": {
    prefix: "class|def|module|begin|if|until|while",
    suffix: "\\{|\\||o"
  }
}

const EndBlockSymbols = {
  "ruby": "\}|end"
}

// return the #tabs needed
function countIndent() {
  const startBlock = function(lang, lineOfCode) {
    let numOfTabs = (lineOfCode.match(/\t/g) || []).length;

    let prefixBeginBlockRegex = new RegExp(`\\t*${BeginBlockSymbols[lang].prefix}`);
    let suffixBeginBlockRegex = new RegExp(`${BeginBlockSymbols[lang].suffix}\\n$`);
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