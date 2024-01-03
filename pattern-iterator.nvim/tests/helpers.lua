local M = {}

---Formats text and split to lines.
---@param text string
---@return string[]
M.get_user_lines = function(text)
  text = text or ""
  local lines = vim.fn.split(text, "\n")

  -- Remove first line if empty
  if lines[1] and lines[1]:match("^[%s]*$") then
    table.remove(lines, 1)
  end

  -- Remove last line if empty
  if lines[#lines] and lines[#lines]:match("^[%s]*$") then
    table.remove(lines, #lines)
  end

  -- Find minimal prepending space gap
  local min_prepending_gap = lines[1]:match("^[%s]*"):len()
  for _, line in pairs(lines) do
    local prepending_gap = line:match("^[%s]*"):len()
    if prepending_gap > 0 and prepending_gap < min_prepending_gap then
      min_prepending_gap = prepending_gap
    end
  end

  -- Remove the prepending space gap
  for i, line in pairs(lines) do
    lines[i] = line:sub(min_prepending_gap + 1)
  end

  return lines
end

---Returns a function that resets neovim state
---@param buffer_text string to set current buffer
---@param cursor_position? number[] position to place the cursor
---@return function
M.get_preset = function(buffer_text, cursor_position)
  cursor_position = cursor_position or { 1, 0 }

  return function()
    -- Reset mode
    M.reset_mode()

    -- Reset options
    vim.go.selection = "inclusive"

    -- Reset last visual selection mode
    local last_visual_mode = nil
    while last_visual_mode ~= "" do
      last_visual_mode = vim.fn.visualmode(1)
    end

    -- Reset last selected region
    vim.api.nvim_buf_set_mark(0, "<", 0, 0, {})
    vim.api.nvim_buf_set_mark(0, ">", 0, 0, {})

    -- Wait for deferred cleanups
    vim.wait(0)

    -- Set the current buffer
    local lines = M.get_user_lines(buffer_text)
    local last_line_index = vim.api.nvim_buf_line_count(0)
    vim.api.nvim_buf_set_lines(0, 0, last_line_index, true, lines)

    -- Set the cursor
    M.set_cursor(unpack(cursor_position))
  end
end

M.trigger_visual = function()
  vim.api.nvim_feedkeys("v", "n", false)
  -- Wait for visual mode to take place.
  M.perform_through_keymap(function() end, true)
end

M.trigger_insert = function()
  vim.api.nvim_feedkeys("i", "n", false)
end

M.trigger_delete = function()
  vim.api.nvim_feedkeys("d", "n", false)
end

M.reset_mode = function()
  local escape = vim.api.nvim_replace_termcodes("<esc>", true, false, true)
  vim.api.nvim_feedkeys(escape, "nx", false)
end

---@param keys string
---@param wait_for_finish boolean
M.feedkeys = function(keys, wait_for_finish)
  local flags = "n"
  if wait_for_finish then
    flags = flags .. "x"
  end

  keys = vim.api.nvim_replace_termcodes(keys, true, false, true)
  vim.api.nvim_feedkeys(keys, flags, false)
end

---@param line number 1-bazed
---@param column number 0-bazed virtual column
M.set_cursor = function(line, column)
  local line_length = vim.fn.virtcol({ line, "$" }) - 1
  if column == line_length then
    -- vim.fn.virtcol2col converts position to a '\n' the same way
    -- as if it converts position to a last character.
    -- so, do it manually.
    column = vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:len()
  else
    column = vim.fn.virtcol2col(0, line, column + 1) - 1
  end

  vim.api.nvim_win_set_cursor(0, { line, column })
end

---Performs a given function with given arguments through a keymap
---@param fn function to perofrm
---@param wait_for_finish boolean
---@param ... any arguments for fn
M.perform_through_keymap = function(fn, wait_for_finish, ...)
  local args = {...}
  local map_label = "<Plug>(perform_through_keymap)"
  vim.keymap.set({ "n", "o", "x", "i" }, map_label, function()
    fn(unpack(args))
  end)
  local keys = vim.api.nvim_replace_termcodes(map_label, true, false, true)

  local feedkeys_flags = wait_for_finish and "x" or ""
  vim.api.nvim_feedkeys(keys, feedkeys_flags, false)
end

return M
