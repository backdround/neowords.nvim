local M = {}

---Returns line size in characters.
---@param line_index number
---@param count_n boolean "\n" should be counted
---@return number
M.line_length = function(line_index, count_n)
  local length = vim.fn.getcharpos({ line_index, "$" })[3]

  if count_n then
    return length
  end

  return math.max(1, length - 1)
end

---@return table
M.get_cursor = function()
  local position = vim.fn.getcursorcharpos()
  return {
    position[2],
    position[3],
  }
end

---Places the given position in bound of the current buffer.
---@param line number
---@param char_index number
---@param n_is_pointable boolean position can point to a "\n"
---@return number[] { line, char_index }
M.place_in_bounds = function(line, char_index, n_is_pointable)
  local last_line = vim.api.nvim_buf_line_count(0)
  if line > last_line then
    return {
      last_line,
      M.line_length(last_line, n_is_pointable),
    }
  end

  if line < 1 then
    return { 1, 1 }
  end

  local max_char_index = M.line_length(line, n_is_pointable)
  char_index = math.min(char_index, max_char_index)
  char_index = math.max(char_index, 1)

  return { line, char_index }
end

return M
