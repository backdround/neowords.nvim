local lazy_rabbit_hop = function(options)
  local rabbit_hop = require("rabbit-hop.api").hop
  return rabbit_hop(options)
end

local M = {}

---@class RH_PluginOptions
---@field pattern string
---@field direction? "forward"|"backward"
---@field match_position? "start"|"end" Sets which end of the match to use.
---@field offset? number Advances final position relatively match_position.
---@field insert_mode_target_side? "left"|"right" side to place the cursor in insert mode.
---@field accept_policy? "from-after-cursor"|"from-cursor"|"any" Indicates whether a potential position should be accepted.
---@field fold_policy? "ignore"|"hop-once"|"hop-in-and-open" Decides how to deal with folds.

---@param plugin_options RH_PluginOptions
---@return boolean The hop has been performed.
M.hop = function(plugin_options)
  ---@type RH_ApiHopOptions
  local api_options = {
    pattern = plugin_options.pattern,
    direction = plugin_options.direction,
    match_position = plugin_options.match_position,
    offset = plugin_options.offset,
    insert_mode_target_side = plugin_options.insert_mode_target_side,
    accept_policy = plugin_options.accept_policy,
    fold_policy = plugin_options.fold_policy,
  }

  if vim.v.count ~= 0 then
    api_options.count = vim.v.count
  else
    api_options.count = 1
  end

  return lazy_rabbit_hop(api_options)
end

return M
