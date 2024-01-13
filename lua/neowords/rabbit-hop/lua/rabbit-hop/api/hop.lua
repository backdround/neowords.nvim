local current_plugin_path = ({ ... })[1]:gsub("[^.]+%.[^.]+$", "")
local pattern_iterator = require(current_plugin_path .. "pattern-iterator.lua.pattern-iterator")
local position = require(current_plugin_path .. "pattern-iterator.lua.pattern-iterator.position")
local new_position_checker = require(current_plugin_path .. "api.position-checker").new

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

---@param opts RH_HopOptions
---@param match PI_Match
---@return PI_Position
local apply_offset = function(opts, match)
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

---@param opts RH_HopOptions
---@param n_is_pointable boolean position can point to a "\n"
---@return PI_Position|nil
local function search_target_position(opts, n_is_pointable)
  local iterator_opts = { n_is_pointable = n_is_pointable }

  local iterator = pattern_iterator.new_around(opts.pattern, iterator_opts)
  if iterator == nil then
    if opts.direction == "forward" then
      iterator = pattern_iterator.new_forward(opts.pattern, iterator_opts)
    else
      iterator = pattern_iterator.new_backward(opts.pattern, iterator_opts)
    end
  end

  if iterator == nil then
    return nil
  end

  local count = opts.count
  local final_position = nil
  local position_checker =
    new_position_checker(opts.direction, opts.accept_policy, opts.fold_policy)
  while true do
    local potential_target_position = apply_offset(opts, iterator)

    if position_checker:is_suitable(potential_target_position) then
      count = count - 1
      final_position = potential_target_position
    end

    if count == 0 then
      return final_position
    end

    local next_match_is_found = false
    if opts.direction == "forward" then
      next_match_is_found = iterator:next()
    else
      next_match_is_found = iterator:previous()
    end

    if not next_match_is_found then
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
---@field accept_policy "from-after-cursor"|"from-cursor"|"any" Indicates whether a potential position should be accepted.
---@field fold_policy? "ignore"|"hop-once"|"hop-in-and-open" Decides how to deal with folds.
---@field count number count of hops to perform

---Performs a hop to a given pattern
---@param opts RH_HopOptions
---@return boolean The hop has been performed.
local perform = function(opts)
  local n_is_pointable = mode() ~= "normal"

  local target_position = search_target_position(opts, n_is_pointable)

  if not target_position then
    return false
  end

  if mode() ~= "operator-pending" then
    target_position:set_cursor()
    return true
  end

  local start_position = position.from_cursor(n_is_pointable)
  if target_position < start_position then
    start_position:move(-1)
  end

  start_position:select_region_to(target_position)
  return true
end

return perform
