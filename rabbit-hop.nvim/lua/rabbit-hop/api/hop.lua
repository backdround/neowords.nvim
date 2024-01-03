local pattern_iterator = require(({ ... })[1]:gsub("[^.]+%.[^.]+$", "") .. "pattern-iterator")
local position = require(({ ... })[1]:gsub("[^.]+%.[^.]+$", "") .. "pattern-iterator.position")

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

---@param pattern string
---@param count number
---@param n_is_pointable boolean position can point to a "\n"
---@param apply_offset function
---@return PI_Position|nil
local function search_forward_target_position(pattern, count, n_is_pointable, apply_offset)
  local iterator_opts = { n_is_pointable = n_is_pointable }

  local iterator = pattern_iterator.new_around(pattern, iterator_opts) or
    pattern_iterator.new_forward(pattern, iterator_opts)

  if iterator == nil then
    return nil
  end

  local final_position = nil
  while true do
    local potential_target_position = apply_offset(iterator)

    if potential_target_position:after_cursor() then
      count = count - 1
      final_position = potential_target_position
    end

    if count == 0 or not iterator:next() then
      return final_position
    end
  end
end

---@param pattern string
---@param count number
---@param n_is_pointable boolean position can point to a "\n"
---@param apply_offset function
---@return PI_Position|nil
local function search_backward_target_position(pattern, count, n_is_pointable, apply_offset)
  local iterator_opts = { n_is_pointable = n_is_pointable }

  local iterator = pattern_iterator.new_around(pattern, iterator_opts) or
    pattern_iterator.new_backward(pattern, iterator_opts)

  if iterator == nil then
    return nil
  end

  local final_position = nil
  while true do
    local potential_target_position = apply_offset(iterator)

    if potential_target_position:before_cursor() then
      count = count - 1
      final_position = potential_target_position
    end

    if count == 0 or not iterator:previous() then
      return final_position
    end
  end
end

---Options that describe the hop behaviour.
---@class RH_HopOptions
---@field pattern string
---@field direction "forward"|"backward"
---@field match_position "start"|"end" Indicates which end of the match to use.
---@field offset number Advances final position relatively match_position.
---@field insert_mode_target_side "left"|"right" side to place the cursor in insert mode.
---@field count number count of hops to perform

---Performs a hop to a given pattern
---@param opts RH_HopOptions
local perform = function(opts)
  local apply_offset = function(match)
    local p = nil
    if opts.match_position == "start" then
      p = match:start_position()
    else
      p = match:end_position()
    end

    p:move(opts.offset)

    if mode() == "insert" then
      if opts.insert_mode_target_side == "right" then
        p:move(1)
      end
    elseif mode() == "visual" then
      if vim.go.selection == "exclusive" and opts.direction == "forward" then
        p:move(1)
      end
    end

    return p
  end

  local n_is_pointable = mode() ~= "normal"

  local target_position = nil
  if opts.direction == "forward" then
    target_position = search_forward_target_position(
      opts.pattern,
      opts.count,
      n_is_pointable,
      apply_offset
    )
  else
    target_position = search_backward_target_position(
      opts.pattern,
      opts.count,
      n_is_pointable,
      apply_offset
    )
  end

  if not target_position then
    return
  end

  if mode() ~= "operator-pending" then
    target_position:set_cursor()
    return
  end

  local start_position = position.from_cursor(n_is_pointable)
  if opts.direction == "backward" then
    start_position:move(-1)
  end

  start_position:select_region_to(target_position)
end

return perform
