local rh = require("rabbit-hop.api")
local M = {}

---Performs the rh.hop through a keymap
---@param direction "forward"|"backward"|nil
---@param offset "pre"|"start"|"end"|"post"|nil
---@param pattern string
---@param additional_options table|nil
M.hop = function(direction, offset, pattern, additional_options)
  local hop_options = additional_options or {}
  hop_options.direction = direction
  hop_options.offset = offset
  hop_options.pattern = pattern

  require("tests.helpers").perform_through_keymap(rh.hop, true, hop_options)
end

return M
