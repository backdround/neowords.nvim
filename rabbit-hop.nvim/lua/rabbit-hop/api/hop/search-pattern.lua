-- require("./position/")
local position = require(({...})[1]:gsub("[^.]+$", "") .. "position")

---@class RH_PatternPosition
---@field start_position RH_Position
---@field end_position RH_Position

---@param pattern string
---@param direction "forward"|"backward"
---@param count number
---@param is_suitable fun(pattern_position: RH_PatternPosition): boolean
---@param n_is_pointable boolean position can point to a "\n"
---@return RH_PatternPosition|nil
local function search_pattern(pattern, direction, count, is_suitable, n_is_pointable)
  local flags = "cnW"
  if direction == "backward" then
    flags = flags .. "b"
  end

  local found_pattern = nil
  local search_callback = function()
    -- Get potential found pattern
    local potential_found_pattern = {
      start_position = position.from_cursor(n_is_pointable)
    }

    local find_end_position = function()
      potential_found_pattern.end_position =
        position.from_cursor(n_is_pointable)
      return 0
    end
    vim.fn.searchpos(pattern, "nWce", nil, nil, find_end_position)

    -- Check the potential position
    if not is_suitable(potential_found_pattern) then
      return 1
    end

    -- Save pattern
    found_pattern = potential_found_pattern

    -- Count down
    count = count - 1
    return count
  end

  vim.fn.searchpos(pattern, flags, nil, nil, search_callback)

  return found_pattern
end

return search_pattern
