local position = require(... .. ".position")
local search_pattern = require(... .. ".search-pattern")

---@return "operator-pending"|"visual"|"normal"|"insert"
local mode = function()
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

---@param pattern_position RH_PatternPosition
---@param opts RH_HopOptions
---@return RH_Position
local function get_position_from_pattern(pattern_position, opts)
  local choose_position_based_on_offset = function()
    local pattern_start = position.copy(pattern_position.start_position)
    local pattern_end = position.copy(pattern_position.end_position)

    if opts.direction == "forward" then
      if opts.offset == "pre" then
        pattern_start.backward_once()
        return pattern_start
      elseif opts.offset == "start" then
        return pattern_start
      elseif opts.offset == "end" then
        return pattern_end
      elseif opts.offset == "post" then
        pattern_end.forward_once()
        return pattern_end
      end
    end

    if opts.direction == "backward" then
      if opts.offset == "pre" then
        pattern_end.forward_once()
        return pattern_end
      elseif opts.offset == "end" then
        return pattern_end
      elseif opts.offset == "start" then
        return pattern_start
      elseif opts.offset == "post" then
        pattern_start.backward_once()
        return pattern_start
      end
    end

    error(
      ("Unknown direction or offset: %s %s"):format(
        tostring(opts.direction),
        tostring(opts.offset)
      )
    )
  end

  local target_position = choose_position_based_on_offset()

  if mode() == "insert" and opts.insert_mode_target_side == "right" then
    target_position.forward_once()
  end

  return target_position
end

---@param opts RH_HopOptions
---@param n_is_pointable boolean position can point to a "\n"
---@return RH_Position|nil
local function search_target_position(opts, n_is_pointable)
  local initial_position = position.from_cursor(n_is_pointable)

  ---@param potential_pattern_position RH_PatternPosition
  ---@return boolean
  local is_pattern_position_suitable = function(potential_pattern_position)
    local potential_position = get_position_from_pattern(
      potential_pattern_position,
      opts
    )

    if opts.direction == "forward" then
      return potential_position > initial_position
    end
    return potential_position < initial_position
  end

  local target_pattern = search_pattern(
    opts.pattern,
    opts.direction,
    opts.count,
    is_pattern_position_suitable,
    n_is_pointable
  )

  if not target_pattern then
    return nil
  end

  return get_position_from_pattern(target_pattern, opts)
end

---Options that describe the hop behaviour.
---@class RH_HopOptions
---@field direction "forward"|"backward" direction to search a given pattern
---@field offset "pre"|"start"|"end"|"post" offset of the cursor to the place
---@field pattern string pattern to search
---@field insert_mode_target_side "left"|"right" side to place the cursor in insert mode
---@field count number count of hops to perform

---Performs a hop to a given pattern
---@param opts RH_HopOptions
local perform = function(opts)
  local n_is_pointable = mode() ~= "normal"
  local target_position = search_target_position(opts, n_is_pointable)

  if not target_position then
    return
  end

  if
    mode() == "visual"
    and vim.go.selection == "exclusive"
    and opts.direction == "forward"
  then
    target_position.forward_once()
  end

  if mode() ~= "operator-pending" then
    target_position.set_cursor()
    return
  end

  local start_position = position.from_cursor(n_is_pointable)
  if opts.direction == "backward" then
    start_position.backward_once()
  end

  start_position.select_region_to(target_position)
end

return perform
