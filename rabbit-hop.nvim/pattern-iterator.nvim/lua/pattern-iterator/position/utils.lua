local M = {}

---@return "operator-pending"|"visual"|"normal"|"insert"
M.mode = function()
  local m = tostring(vim.fn.mode(true))

  if m:find("o") then
    return "operator-pending"
  elseif m:find("[vV]") then
    return "visual"
  elseif m:find("i") then
    return "insert"
  else
    return "normal"
  end
end

---Returns line size in virtual columns.
---@param line_index number
---@param n_is_pointable boolean position can point to a "\n"
---@return number
M.virtual_line_length = function(line_index, n_is_pointable)
  local length = vim.fn.virtcol({ line_index, "$" })

  if n_is_pointable then
    return length
  end

  return math.max(1, length - 1)
end

---Converts a virtual position to a byte position.
---@param virtual_position number[]
---@return number[]
M.from_virtual_to_byte = function(virtual_position)
  local line = virtual_position[1]
  local column = vim.fn.virtcol2col(0, line, virtual_position[2] + 1) - 1

  -- vim.fn.virtcol2col converts position to a '\n' the same way
  -- as if it converts position to a last character.
  -- so, do it manually:
  if virtual_position[2] == M.virtual_line_length(line, true) - 1 then
    column = vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:len()
  end

  return { line, column }
end

---Converts a byte position to a virtual position.
---@param byte_position number[]
---@return number[]
M.from_byte_to_virtual = function(byte_position)
  local line = byte_position[1]
  local column = vim.fn.virtcol(byte_position)
  return { line, column }
end

---Places the given position in bound of the current buffer.
---@param position number[] virtual position.
---@param n_is_pointable boolean position can point to a "\n"
---@return number[]
M.place_in_bounds = function(position, n_is_pointable)
  local line = position[1]
  local column = position[2]

  local last_line = vim.api.nvim_buf_line_count(0)
  if line > last_line then
    return {
      last_line,
      M.virtual_line_length(last_line, n_is_pointable) - 1,
    }
  end

  if line < 1 then
    return { 1, 0, }
  end

  local max_column = M.virtual_line_length(line, n_is_pointable) - 1
  column = math.min(column, max_column)
  column = math.max(column, 0)

  return { line, column }
end

return M
