local rabbit_hop_api = require("rabbit-hop.api")
local h = require("tests.helpers")

local M = {}

---Performs the rabbit-hop.api.hop through a keymap
---@param pattern string
---@param direction? "forward"|"backward"
---@param match_position? "start"|"end"
---@param additional_options? table|nil
---@return boolean The hop has been performed.
M.hop = function(pattern, direction, match_position, additional_options)
  local hop_options = vim.deepcopy(additional_options or {})

  hop_options.direction = direction
  hop_options.match_position = match_position
  hop_options.pattern = pattern

  local result = nil
  h.perform_through_keymap(function()
    result = rabbit_hop_api.hop(hop_options)
  end, true)
  return result
end

return M
