local hop_api = require("rabbit-hop.api")

local M = {}

---@class RH_PluginOptions
---@field pattern string
---@field direction? "forward"|"backward"
---@field offset? "pre"|"start"|"end"|"post"
---@field insert_mode_target_side? "left"|"right" side to place the cursor in insert mode

---@param plugin_options RH_PluginOptions
M.hop = function(plugin_options)
  ---@type RH_ApiHopOptions
  local api_options = {
    pattern = plugin_options.pattern,
    direction = plugin_options.direction,
    offset = plugin_options.offset,
    insert_mode_target_side = plugin_options.insert_mode_target_side,
  }

  if vim.v.count ~= 0 then
    api_options.count = vim.v.count
  else
    api_options.count = 1
  end

  hop_api.hop(api_options)
end

return M
