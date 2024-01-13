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

local function selected_region(_, arguments)
  local expected_left_mark = arguments[1]
  local expected_right_mark = arguments[2]

  -- Reset visual mode if it's in visual
  local restore_visual_mode = false
  if tostring(vim.fn.mode(true)):find("[vV]") ~= nil then
    restore_visual_mode = true
    local esc = vim.api.nvim_replace_termcodes("<esc>", true, false, true)
    vim.api.nvim_feedkeys(esc, "nx", false)
  end

  local real_left_mark = get_char_position("'<")
  local real_right_mark = get_char_position("'>")

  if restore_visual_mode then
    vim.api.nvim_feedkeys("gv", "nx", false)
  end

  table.insert(arguments, 1, vim.inspect(real_left_mark))
  table.insert(arguments, 2, vim.inspect(real_right_mark))
  table.insert(arguments, 3, vim.inspect(expected_left_mark))
  table.insert(arguments, 4, vim.inspect(expected_right_mark))
  arguments.nofmt = { 1, 2, 3, 4 }

  local left_is_equal = vim.deep_equal(expected_left_mark, real_left_mark)
  local right_is_equal = vim.deep_equal(expected_right_mark, real_right_mark)

  return left_is_equal and right_is_equal
end

local function match_position(_, arguments)
  local real_match_position = arguments[1]
  local expected_start_position = arguments[2]
  local expected_end_position = arguments[3]

  if real_match_position == nil then
    arguments[1] = "nil"
  else
    arguments[1] = ("{ start_position = %s, end_position = %s }"):format(
      tostring(real_match_position.start_position),
      tostring(real_match_position.end_position)
    )
  end
  local expected_pattern =
    "{ start_position = { %s, %s }, end_position = { %s, %s } }"
  arguments[2] = expected_pattern:format(
    expected_start_position[1],
    expected_start_position[2],
    expected_end_position[1],
    expected_end_position[2]
  )
  arguments.nofmt = { 1, 2 }

  if real_match_position == nil then
    return false
  end

  return real_match_position.start_position.line == expected_start_position[1]
    and real_match_position.start_position.char_index == expected_start_position[2]
    and real_match_position.end_position.line == expected_end_position[1]
    and real_match_position.end_position.char_index == expected_end_position[2]
end

local function iterator(_, arguments)
  local real_iterator = arguments[1]
  local expected_start_position = arguments[2]
  local expected_end_position = arguments[3]

  if real_iterator == nil then
    arguments[1] = "nil"
  else
    arguments[1] = ("{ start_position = %s, end_position = %s }"):format(
      tostring(real_iterator:start_position()),
      tostring(real_iterator:end_position())
    )
  end
  local expected_pattern =
    "{ start_position = { %s, %s }, end_position = { %s, %s } }"
  arguments[2] = expected_pattern:format(
    expected_start_position[1],
    expected_start_position[2],
    expected_end_position[1],
    expected_end_position[2]
  )
  arguments.nofmt = { 1, 2 }

  if real_iterator == nil then
    return false
  end

  local start_position = real_iterator:start_position()
  local end_position = real_iterator:end_position()

  return start_position.line == expected_start_position[1]
    and start_position.char_index == expected_start_position[2]
    and end_position.line == expected_end_position[1]
    and end_position.char_index == expected_end_position[2]
end

local function position(_, arguments)
  local real_position = arguments[1]
  local expected_position = arguments[2]

  if real_position == nil then
    arguments[1] = "nil"
  else
    arguments[1] = ("{ %s, %s, %s }"):format(
      tostring(real_position.line),
      tostring(real_position.char_index),
      tostring(real_position.n_is_pointable)
    )
  end

  local expected_pattern = "{ %s, %s, %s }"
  arguments[2] = expected_pattern:format(
    expected_position[1],
    expected_position[2],
    expected_position[3]
  )

  arguments.nofmt = { 1, 2 }

  if real_position == nil then
    return false
  end

  return real_position.line == expected_position[1]
    and real_position.char_index == expected_position[2]
    and real_position.n_is_pointable == expected_position[3]
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
    "assertion.selected_region",
    "Expected selected region to be:" ..
    "\nReal:\n %s, %s \nExpected:\n %s, %s"
  )
  assert:register(
    "assertion",
    "selected_region",
    selected_region,
    "assertion.selected_region"
  )

  say:set(
    "assertion.match_position",
    "Expected match_position to be:" ..
    "\nReal:\n %s \nExpected:\n %s"
  )
  assert:register(
    "assertion",
    "match_position",
    match_position,
    "assertion.match_position"
  )

  say:set(
    "assertion.iterator",
    "Expected iterator to be:" ..
    "\nReal:\n %s \nExpected:\n %s"
  )
  assert:register(
    "assertion",
    "iterator",
    iterator,
    "assertion.iterator"
  )

  say:set(
    "assertion.position",
    "Expected position to be:" ..
    "\nReal:\n %s \nExpected:\n %s"
  )
  assert:register(
    "assertion",
    "position",
    position,
    "assertion.position"
  )
end

return {
  register = register,
}
