local word_hops = require("neowords.word-hops")
local pattern_presets = require("neowords.pattern-presets")

local M = {
  pattern_presets = pattern_presets,
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

    error(message, 2)
  end,
})

M.get_word_hops = word_hops.get

return M
