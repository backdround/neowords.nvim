local word_hops = require("neowords.word-hops")

local M = {
  pattern_presets = {
    sneak_case = "\\v[[:lower:]]+",
    camel_case = "\\v[[:upper:]][[:lower:]]+",
    upper_case = "\\v[[:upper:]]+[[:lower:]]@!",
    number = "\\v[[:digit:]]+",
    hex_color = "\\v#[[:xdigit:]]+",

    any_word = "\\v-@![[:alpha:]-_]+",
  }
}

setmetatable(M.pattern_presets, {
  __index = function(_, key)
    local format = "The key %s doesn't exist in the pattern_presets"
    error(format:format(tostring(key)))
  end
})

M.get_word_hops = word_hops.get

return M
