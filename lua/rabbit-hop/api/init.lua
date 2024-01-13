local hop = require(... .. ".hop")
local api_options_utils = require(... .. ".api-options-utils")

local M = {}

---@param api_hop_options RH_ApiHopOptions
---@return boolean The hop has been performed.
M.hop = function(api_hop_options)
  local hop_options = api_options_utils.get_hop_options(api_hop_options)
  local result =  hop(hop_options)

  if api_hop_options.fold_policy == "hop-in-and-open" then
    vim.cmd.normal({ args = { "zv" }, bang = true })
  end

  return result
end

return M
