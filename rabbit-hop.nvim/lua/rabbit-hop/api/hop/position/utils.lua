local M = {}

---Returns line size in virtual columns.
---@param line_index number
---@param n_is_pointable boolean position can point to a "\n"
---@return number
M.virtual_line_length = function(line_index, n_is_pointable)
  local length = vim.fn.virtcol({ line_index, "$" }) - 1

  if n_is_pointable then
    return length
  end

  return length - 1
end

---@Converts a virtual position to a byte position.
---@param virtual_position number[]
---@return number[]
M.from_virtual_to_byte = function(virtual_position)
  local line = virtual_position[1]
  local column = vim.fn.virtcol2col(0, line, virtual_position[2] + 1) - 1

  -- vim.fn.virtcol2col converts position to a '\n' the same way
  -- as if it converts position to a last character.
  -- so, do it manually:
  if virtual_position[2] == M.virtual_line_length(line, true) then
    local current_line_size =
      vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:len()
    column = current_line_size + 1
  end

  return { line, column }
end

---@Converts a byte position to a virtual position.
---@param byte_position number[]
---@return number[]
M.from_byte_to_virtual = function(byte_position)
  local line = byte_position[1]
  local column = vim.fn.virtcol(byte_position)
  return { line, column }
end

return M
