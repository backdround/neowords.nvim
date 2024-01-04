local utils = require(... .. ".utils")

---Represents a position.
---@class PI_Position
---@field line number line
---@field column number virtual column
---@field n_is_pointable boolean position can point to a \n

local M = {}

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
  end,

  __tostring = function(p)
    return "{ " .. p.line .. ", " .. p.column .. " }"
  end
}

---@param line number line
---@param column number virtual column
---@param n_is_pointable boolean position can point to a \n
---@return PI_Position
local new_position = function(line, column, n_is_pointable)
  ---@class PI_Position
  local p = {
    line = line,
    column = column,
    n_is_pointable = n_is_pointable,
  }

  setmetatable(p, position_metatable)

  ---Sets the cursor to the current position.
  ---@param self PI_Position
  p.set_cursor = function(self)
    local byte_position = utils.from_virtual_to_byte({ self.line, self.column })
    vim.api.nvim_win_set_cursor(0, byte_position)
  end

  ---Indicates that the current position is after the cursor.
  ---@param self PI_Position
  ---@return boolean
  p.after_cursor = function(self)
    local byte_cursor_position = vim.api.nvim_win_get_cursor(0)
    local cursor_position = utils.from_byte_to_virtual(byte_cursor_position)

    if self.line == cursor_position[1] then
      return self.column > cursor_position[2]
    end
    return self.line > cursor_position[1]
  end

  ---Indicates that the current position is before the cursor.
  ---@param self PI_Position
  ---@return boolean
  p.before_cursor = function(self)
    local byte_cursor_position = vim.api.nvim_win_get_cursor(0)
    local cursor_position = utils.from_byte_to_virtual(byte_cursor_position)

    if self.line == cursor_position[1] then
      return self.column < cursor_position[2]
    end
    return self.line < cursor_position[1]
  end

  ---Selects a region from the current position to a given position.
  ---@param self PI_Position
  ---@param position PI_Position
  p.select_region_to = function(self, position)
    local p1 = vim.deepcopy(self)
    local p2 = vim.deepcopy(position)

    if p1 > p2 then
      p1, p2 = p2, p1
    end

    local selection = vim.api.nvim_get_option_value("selection", {})
    if selection == "exclusive" then
      p2:move(1)
    end

    -- Use vim.fn.setcharpos instead vim.api.nvim_buf_set_mark, because the
    -- later ignores subsequent <bs>'s.
    vim.fn.setcharpos("'<", { 0, p1.line, p1.column + 1, 0 })
    vim.fn.setcharpos("'>", { 0, p2.line, p2.column + 1, 0 })

    local keys_to_select_marks = "gv"
    if vim.fn.visualmode() ~= "v" and vim.fn.visualmode() ~= "" then
      keys_to_select_marks = "gvv"
    end

    vim.cmd.normal({ args = { keys_to_select_marks }, bang = true })
  end

  ---Sets new n_is_pointable
  ---@param self PI_Position
  ---@param new_n_is_pointable boolean
  p.set_n_is_pointable = function(self, new_n_is_pointable)
    local line_length = utils.virtual_line_length(self.line, new_n_is_pointable)
    if new_n_is_pointable == false and self.column == line_length then
      -- Correct column
      self.column = math.max(1, line_length - 1)
    end

    self.n_is_pointable = new_n_is_pointable
  end

  local move_forward = function(self, offset)
    local last_line = vim.api.nvim_buf_line_count(0)
    while true do
      local line_length =
        utils.virtual_line_length(self.line, self.n_is_pointable)
      local available_places_on_line = (line_length - 1) - self.column

      if available_places_on_line >= offset then
        self.column = self.column + offset
        return
      end

      if self.line == last_line then
        self.column = line_length - 1
        return
      end

      self.column = 0
      self.line = self.line + 1
      offset = offset - (available_places_on_line + 1)
    end
  end

  local move_backward = function(self, offset)
    while true do
      if self.column >= offset then
        self.column = self.column - offset
        return
      end

      if self.line == 1 then
        self.column = 0
        return
      end

      offset = offset - (self.column + 1)
      self.line = self.line - 1
      local line_length =
        utils.virtual_line_length(self.line, self.n_is_pointable)
      self.column = line_length - 1
    end
  end

  ---Moves the position according to the offset. If offset > 0 then it moves
  ---forward else backward.
  ---@param self PI_Position
  ---@param offset number
  p.move = function(self, offset)
    if offset > 0 then
      move_forward(self, offset)
    else
      move_backward(self, math.abs(offset))
    end
  end

  return p
end

local prototype = new_position(0, 0, true)

---Creates PI_Position from the position of the current cursor.
---@param n_is_pointable boolean position can point to a \n
---@return PI_Position
M.from_cursor = function(n_is_pointable)
  if n_is_pointable == nil then
    n_is_pointable = false
  end

  local byte_position = vim.api.nvim_win_get_cursor(0)
  local cursor_position = utils.from_byte_to_virtual(byte_position)
  cursor_position = utils.place_in_bounds(cursor_position, n_is_pointable)

  local final_position = vim.deepcopy(prototype)
  final_position.line = cursor_position[1]
  final_position.column = cursor_position[2]
  final_position:set_n_is_pointable(n_is_pointable)

  return final_position
end

---Creates PI_Position from the given virtual position.
---@param line number virtual line
---@param column number virtual column
---@param n_is_pointable? boolean position can point to a \n
M.from_coordinates = function(line, column, n_is_pointable)
  if n_is_pointable == nil then
    n_is_pointable = false
  end

  if type(line) ~= "number" or type(column) ~= "number" then
    error("Line and column must be numbers")
  end

  local coordinates = utils.place_in_bounds({ line, column }, n_is_pointable)

  local final_position = vim.deepcopy(prototype)
  final_position.line = coordinates[1]
  final_position.column = coordinates[2]
  final_position:set_n_is_pointable(n_is_pointable)

  return final_position
end

return M
