local hop = require(... .. ".hop")
local api_options_utils = require(... .. ".api-options-utils")

local M = {}

---@param api_hop_options RH_ApiHopOptions
M.hop = function(api_hop_options)
  local hop_options = api_options_utils.get_hop_options(api_hop_options)
  hop(hop_options)
end

return M
