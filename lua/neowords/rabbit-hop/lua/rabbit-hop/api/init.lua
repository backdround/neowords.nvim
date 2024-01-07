local hop = require(... .. ".hop")
local api_options_utils = require(... .. ".api-options-utils")

local M = {}

---@param api_hop_options RH_ApiHopOptions
---@return boolean The hop has been performed.
M.hop = function(api_hop_options)
  local hop_options = api_options_utils.get_hop_options(api_hop_options)
  return hop(hop_options)
end

return M
