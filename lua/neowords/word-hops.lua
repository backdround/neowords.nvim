local rabbit_hop = require("neowords.rabbit-hop.api")

local M = {}

local is_operator_pending_mode = function()
  local m = tostring(vim.fn.mode(true))
  if m:find("o") then
    return true
  end
  return false
end

---Unites patterns into one pattern
---@param ... string
---@return string
local unite_patterns = function(...)
  local patterns = {...}

  local result_pattern = "\\v(" .. table.remove(patterns, 1)
  for _, pattern in ipairs(patterns) do
    result_pattern = result_pattern .. "\\v|" .. pattern
  end
  result_pattern = result_pattern .. "\\v)"
  return result_pattern
end

---@class NW_WordHops
---@field forward_start function hop forward to a pattern start
---@field forward_end function hop forward to a pattern end
---@field backward_start function hop backward to a pattern start
---@field backward_end function hop backward to a pattern end

---Produces word hops
---@param ... string
---@return NW_WordHops
M.get = function(...)
  local pattern = unite_patterns(...)

  return {
    forward_start = function()
      rabbit_hop.hop({
        direction = "forward",
        offset = is_operator_pending_mode() and "pre" or "start",
        pattern = pattern,
        insert_mode_target_side = "left",
      })
    end,

    forward_end = function()
      rabbit_hop.hop({
        direction = "forward",
        offset = "end",
        pattern = pattern,
        insert_mode_target_side = "right",
      })
    end,

    backward_end = function()
      rabbit_hop.hop({
        direction = "backward",
        offset = is_operator_pending_mode() and "pre" or "end",
        pattern = pattern,
        insert_mode_target_side = "right",
      })
    end,

    backward_start = function()
      rabbit_hop.hop({
        direction = "backward",
        offset = "start",
        pattern = pattern,
        insert_mode_target_side = "left",
      })
    end,
  }
end

return M
