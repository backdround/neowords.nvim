local search_pattern = require(({ ... })[1] .. ".search-pattern")
local position = require(({ ... })[1] .. ".position")
local utils = require(({ ... })[1] .. ".utils")
local new_iterator = require(({ ... })[1] .. ".iterator").new

---Additional options for pattern iterator search.
---@class PI_SearchOptions
---@field n_is_pointable? boolean position can point to a \n.
---@field from_search_position? number[] (1, 0) indexed, line and virtual column.

---Searches a given pattern relatively to the from_search_position or the
---cursor in a given area and returns a new pattern iterator.
---@param pattern string
---@param options? PI_SearchOptions additional options
---@param area string "current"|"forward"|"backward"
local perform_searching = function(pattern, options, area)
  options = options or {}

  local relative_position = nil
  if options.from_search_position ~= nil then
    relative_position = position.from_coordinates(
      options.from_search_position[1],
      options.from_search_position[2],
      true
    )
  else
    relative_position = position.from_cursor(true)
  end

  local n_is_pointable = options.n_is_pointable
  if n_is_pointable == nil then
    n_is_pointable = utils.is_n_pointable()
  end

  local base_match = nil
  if area == "current" then
    base_match = search_pattern.current(pattern, relative_position)
  elseif area == "forward" then
    base_match = search_pattern.next(pattern, relative_position)
  elseif area == "backward" then
    base_match = search_pattern.previous(pattern, relative_position)
  end

  if base_match == nil then
    return nil
  end

  return new_iterator(pattern, base_match, n_is_pointable)
end

---Searches a given pattern at the from_search_position or the cursor
---and returns a new pattern iterator.
---@param pattern string
---@param options? PI_SearchOptions additional options
local new_around = function(pattern, options)
  return perform_searching(pattern, options, "current")
end

---Searches a given pattern after the from_search_position or the cursor
---and returns a new pattern iterator.
---@param pattern string
---@param options? PI_SearchOptions additional options
local new_forward = function(pattern, options)
  return perform_searching(pattern, options, "forward")
end

---Searches a given pattern before the from_search_position or the cursor
---and returns a new pattern iterator.
---@param pattern string
---@param options? PI_SearchOptions additional options
local new_backward = function(pattern, options)
  return perform_searching(pattern, options, "backward")
end

return {
  new_around = new_around,
  new_forward = new_forward,
  new_backward = new_backward,
}
