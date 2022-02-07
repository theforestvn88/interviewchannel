const TWO_SLASHES = "//";
const HASH_SIGN = "#";
const TWO_DASHES = "--";
const PERCENT = "%";

export const CommentPrefix = {
  "default": TWO_SLASHES,
  "sql": TWO_DASHES,
  "erlang": PERCENT,
  "bash": HASH_SIGN,
  "ruby": HASH_SIGN,
  "crytal": HASH_SIGN,
  "elixir": HASH_SIGN,
  "python": HASH_SIGN,
  "perl": HASH_SIGN,
  "julia": HASH_SIGN,
  "r": HASH_SIGN
}

export const BeginBlockSymbols = {
  "default": {
    prefix: "class|if|else",
    suffix: "\\{(\\n)?$"
  },
  "ruby": {
    prefix: "class|def|module|begin|if|else|until|while|case|when|begin|rescue|ensure",
    suffix: "\\{|\\||o(\\n)?$"
  },
  "elixir": {
    prefix: "class|def|module|begin|if|until|while|case|when",
    suffix: "\\{|\\||o(\\n)?$"
  },
  "python": {
    prefix: "class|def",
    suffix: "\\:(\\n)?$"
  },
  "scala": {
    prefix: ".*\\:.*=(\\n)?$",
    suffix: "\\{|\\=\\>(\\n)?$"
  },
  "clojure": {
    prefix: "\\(.+(\\n)?$",
    suffix: undefined
  },
  "erlang": {
    prefix: "fun|if|case",
    suffix: "-\\>(\\n)?$"
  }
}

export const EndBlockSymbols = {
  "default": "\}",
  "ruby": "\}|end",
  "python": undefined,
  "scala": undefined,
  "clojure": undefined,
  "erlang": "end"
}

export const IndentTabs = {
  "default": {
    "size": 3,
    "block": 1
  },
}