local utils = require(... .. ".utils")

-- The variable must be file local in order to '__eq' work properly.
-- lua 5.1 checks getmetatable(p1) == getmetatable(p2) before performing the
-- real check.
local position_metatable = {
  __eq = function(p1, p2)
    return p1.line == p2.line and p1.column == p2.column
  end,

  __lt = function(p1, p2)
    if p1.line < p2.line then
      return true
    end

    if p1.line == p2.line and p1.column < p2.column then
      return true
    end

    return false
  end
}

---@param line number virtual line
---@param column number virtual column
---@param n_is_pointable boolean position can point to a \n
---@return RH_Position
local new_position = function(line, column, n_is_pointable)
  ---Represents possible cursor position.
  ---@class RH_Position
  local p = {
    line = line,
    column = column,
    n_is_pointable = n_is_pointable,
  }

  setmetatable(p, position_metatable)

  local function raw(position)
    return { position.line, position.column }
  end

  ---Sets the cursor to the current position.
  p.set_cursor = function()
    local byte_position = utils.from_virtual_to_byte(raw(p))
    vim.api.nvim_win_set_cursor(0, byte_position)
  end

  ---Selects a region from the current position to a given position.
  ---@param position RH_Position
  p.select_region_to = function(position)
    local byte_position1 = utils.from_virtual_to_byte(raw(p))
    local byte_position2 = utils.from_virtual_to_byte(raw(position))
    vim.api.nvim_buf_set_mark(0, "<", byte_position1[1], byte_position1[2], {})
    vim.api.nvim_buf_set_mark(0, ">", byte_position2[1], byte_position2[2], {})

    vim.cmd("normal! gv")

    if vim.fn.visualmode() ~= "v" and vim.fn.visualmode() ~= "" then
      vim.cmd("normal! v")
    end
  end

  ---Moves the position backward once in the current buffer.
  p.backward_once = function()
    if p.line == 1 and p.column == 0 then
      return
    end

    if p.column == 0 then
      p.line = p.line - 1
      p.column = utils.virtual_line_length(p.line, p.n_is_pointable)
      return
    end

    p.column = p.column - 1
  end

  ---Moves the position forward once in the current buffer.
  p.forward_once = function()
    local last_buffer_line = vim.api.nvim_buf_line_count(0)
    local current_line_length =
      utils.virtual_line_length(p.line, p.n_is_pointable)

    if p.line == last_buffer_line and p.column == current_line_length then
      return
    end

    if p.column == current_line_length then
      p.line = p.line + 1
      p.column = 0
      return
    end

    p.column = p.column + 1
  end

  return p
end

local M = {}

---Creates RH_Position from the position of the current cursor.
---@param n_is_pointable boolean position can point to a \n
---@return RH_Position
M.from_cursor = function(n_is_pointable)
  local byte_position = vim.api.nvim_win_get_cursor(0)
  local position = utils.from_byte_to_virtual(byte_position)
  return new_position(position[1], position[2], n_is_pointable)
end

---Creates RH_Position from an existing RH_Position
---@param p RH_Position
---@return RH_Position
M.copy = function(p)
  return new_position(p.line, p.column, p.n_is_pointable)
end

return M
