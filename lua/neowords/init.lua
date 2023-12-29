local word_hops = require("neowords.word-hops")

local M = {
  pattern_presets = {
    snake_case = "\\v[[:lower:]]+",
    camel_case = "\\v[[:upper:]][[:lower:]]+",
    upper_case = "\\v[[:upper:]]+[[:lower:]]@!",
    number = "\\v[[:digit:]]+",
    hex_color = "\\v#[[:xdigit:]]+",

    any_word = "\\v-@![-_[:lower:][:upper:]]+",
  }
}

setmetatable(M.pattern_presets, {
  __index = function(_, key)
    local message = "  \n The key '"
      .. tostring(key)
      .. "' doesn't exist in the pattern_presets:"
      .. "\n  Possible keys:"
    for possible_key in pairs(M.pattern_presets) do
      message = message .. "\n   - " .. possible_key
    end

    error(message)
  end,
})

M.get_word_hops = word_hops.get

return M
