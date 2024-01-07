-- require("./utils")
local utils = require(({ ... })[1]:gsub("[^.]+$", "") .. "utils")

---Searches a pattern match that is around the relative_position.
---@param pattern string
---@param relative_position PI_Position
---@return PI_Match?
local search_current = function(pattern, relative_position)
  relative_position:set_cursor()

  local start_match_position = utils.vim_search(pattern, "bcWn")
  if start_match_position == nil then
    return nil
  end

  start_match_position:set_cursor()

  -- Searches the end if the cursor is palced at "$"
  local end_match_position = utils.vim_search(pattern, "becWn")

  if start_match_position ~= end_match_position then
    -- Searches the end in all other cases barring "$"
    end_match_position = utils.vim_search(pattern, "ecWn")
  end

  -- Check that the relative_position is in bounds of the found pattern
  if
    start_match_position > relative_position
    or end_match_position < relative_position
  then
    return nil
  end

  return {
    start_position = start_match_position,
    end_position = end_match_position,
  }
end

---Searches a pattern match that is around the relative_position.
---@param pattern string
---@param relative_position PI_Position
---@return PI_Match?
local current = function(pattern, relative_position)
  local restore_vim_state = utils.prepare_vim_state()

  local result = { search_current(pattern, relative_position) }

  restore_vim_state()
  return unpack(result)
end

return current
