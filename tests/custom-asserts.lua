local assert = require("luassert")
local say = require("say")
local h = require("tests.helpers")

------------------------------------------------------------
-- Utility functions

local function concatenate_lines(lines)
  local text = ""
  for _, line in ipairs(lines) do
    text = text .. "\n" .. line
  end
  text = text:gsub("\n", "", 1)

  return text
end

local function get_char_position(expression)
  local position = vim.fn.getcharpos(expression)
  return {
    position[2],
    position[3],
  }
end

------------------------------------------------------------
-- Assert functions

local function cursor_at(_, arguments)
  local line = arguments[1]
  local char_index = arguments[2]

  local position = get_char_position(".")

  -- Prepare arguments for assert output
  table.insert(arguments, 1, position[1])
  table.insert(arguments, 2, position[2])
  arguments.nofmt = { 1, 2, 3, 4 }

  return line == position[1] and char_index == position[2]
end

local function buffer(_, arguments)
  local user_lines = h.get_user_lines(arguments[1])
  local user_text = concatenate_lines(user_lines)

  local last_line_index = vim.api.nvim_buf_line_count(0)
  local buffer_lines = vim.api.nvim_buf_get_lines(0, 0, last_line_index, true)
  local buffer_text = concatenate_lines(buffer_lines)

  -- Prepare arguments for assert output
  arguments[1] = buffer_text
  arguments[2] = user_text
  arguments.nofmt = { 1, 2 }

  return user_text == buffer_text
end

local function last_selected_region(_, arguments)
  local expected_left_mark = arguments[1]
  local expected_right_mark = arguments[2]


  local real_left_mark = get_char_position("'<")
  local real_right_mark = get_char_position("'>")

  table.insert(arguments, 1, vim.inspect(real_left_mark))
  table.insert(arguments, 2, vim.inspect(real_right_mark))
  table.insert(arguments, 3, vim.inspect(expected_left_mark))
  table.insert(arguments, 4, vim.inspect(expected_right_mark))
  arguments.nofmt = { 1, 2, 3, 4 }

  local left_is_equal = vim.deep_equal(expected_left_mark, real_left_mark)
  local right_is_equal = vim.deep_equal(expected_right_mark, real_right_mark)

  return left_is_equal and right_is_equal
end

local register = function()
  say:set_namespace("en")
  say:set(
    "assertion.cursor_at",
    "Expected the cursor to be at the position:" ..
    "\nReal:\n { %s, %s }\nExpected:\n { %s, %s }"
  )
  assert:register(
    "assertion",
    "cursor_at",
    cursor_at,
    "assertion.cursor_at"
  )

  say:set(
    "assertion.buffer",
    "Expected the buffer to be:" ..
    "\nReal:\n%s\nExpected:\n%s"
  )
  assert:register(
    "assertion",
    "buffer",
    buffer,
    "assertion.buffer"
  )

  say:set(
    "assertion.last_selected_region",
    "Expected selected region to be:" ..
    "\nReal:\n %s, %s \nExpected:\n %s, %s"
  )
  assert:register(
    "assertion",
    "last_selected_region",
    last_selected_region,
    "assertion.last_selected_region"
  )
end

return {
  register = register,
}
