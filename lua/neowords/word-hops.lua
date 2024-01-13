local lazy_rabbit_hop = function(...)
  local rabbit_hop = require("neowords.rabbit-hop.lua.rabbit-hop.api").hop
  return rabbit_hop(unpack({ ... }))
end

local M = {}

local is_operator_pending_mode = function()
  local m = tostring(vim.fn.mode(true))
  if m:find("o") then
    return true
  end
  return false
end

local on_first_character_in_buffer = function()
  local cursor = vim.api.nvim_win_get_cursor(0)
  if cursor[1] == 1 and cursor[2] == 0 then
    return true
  end
  return false
end

---Unites patterns into one pattern
---@param ... string
---@return string
local unite_patterns = function(...)
  local patterns = {...}

  if #patterns == 0 then
    error("At least one pattern must be passed as an argument")
  end

  for _, pattern in ipairs(patterns) do
    if type(pattern) ~= "string" then
      error("The argument must be a string, but it's a " .. type(pattern))
    end
  end

  local result_pattern = "\\v(" .. table.remove(patterns, 1)
  for _, pattern in ipairs(patterns) do
    result_pattern = result_pattern .. "\\v|" .. pattern
  end
  result_pattern = result_pattern .. "\\v)"

  return result_pattern
end

---@return string
M._get_fold_policy = function()
  if not M._foldopen_tracker then
    M._foldopen_tracker = require("neowords.foldopen-tracker").new()
  end

  if M._foldopen_tracker.has_hor() then
    return "hop-in-and-open"
  else
    return "hop-once"
  end
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
      local accept_policy = "from-after-cursor"
      if is_operator_pending_mode() then
        accept_policy = "from-cursor"
      end

      -- Special case when:
      -- - In operator mode
      -- - On the first character in the buffer
      -- - Under the cursor a word that matches the pattern.
      if on_first_character_in_buffer() then
        local position = vim.fn.searchpos(pattern, "nc")
        if position[1] == 1 and position[2] == 1 then
          accept_policy = "from-after-cursor"
        end
      end

      lazy_rabbit_hop({
        direction = "forward",
        match_position = "start",
        offset = is_operator_pending_mode() and -1 or 0,
        pattern = pattern,
        insert_mode_target_side = "left",
        count = vim.v.count1,
        accept_policy = accept_policy,
        fold_policy = M._get_fold_policy(),
      })
    end,

    forward_end = function()
      lazy_rabbit_hop({
        direction = "forward",
        match_position = "end",
        pattern = pattern,
        insert_mode_target_side = "right",
        count = vim.v.count1,
        fold_policy = M._get_fold_policy(),
      })
    end,

    backward_end = function()
      lazy_rabbit_hop({
        direction = "backward",
        match_position = "end",
        offset = is_operator_pending_mode() and 1 or 0,
        pattern = pattern,
        insert_mode_target_side = "right",
        count = vim.v.count1,
        fold_policy = M._get_fold_policy(),
      })
    end,

    backward_start = function()
      lazy_rabbit_hop({
        direction = "backward",
        match_position = "start",
        pattern = pattern,
        insert_mode_target_side = "left",
        count = vim.v.count1,
        fold_policy = M._get_fold_policy(),
      })
    end,
  }
end

return M
