local M = {}

local assert_pattern = function(pattern)
  if type(pattern) ~= "string" then
    error("pattern must be a string, but it is: " .. tostring(type(pattern)))
  end
end

local assert_direction = function(direction)
  if
    direction ~= nil
    and direction ~= "forward"
    and direction ~= "backward"
  then
    error(
      'direction must be one of these "forward"|"backward"|nil, but it is: '
        .. tostring(direction)
    )
  end
end

local assert_match_position = function(match_position)
  if
    match_position ~= nil
    and match_position ~= "start"
    and match_position ~= "end"
  then
    error(
      'match_position must be one of these "start"|"end"|nil, but it is: '
        .. tostring(match_position)
    )
  end
end

local assert_offset = function(offset)
  if offset ~= nil and type(offset) ~= "number" then
    error('offset must be number|nil, but it is: ' .. type(offset))
  end
end

local assert_insert_mode_target_side = function(insert_mode_target_side)
  if
    insert_mode_target_side ~= nil
    and insert_mode_target_side ~= "left"
    and insert_mode_target_side ~= "right"
  then
    error(
      'insert_mode_target_side must be "left"|"right"|nil, but it is: '
        .. tostring(insert_mode_target_side)
    )
  end
end

local assert_count = function(count)
  if count ~= nil and type(count) ~= "number" then
    error("count must be a number|nil, but it is: " .. tostring(type(count)))
  end
end

local assert_accept_policy = function(accept_policy)
  if accept_policy ~= nil and type(accept_policy) ~= "string" then
    error(
      'accept_policy must be "from-after-cursor"|"from-cursor"|"any"|nil, but it is: '
        .. tostring(type(accept_policy))
    )
  end
end

local assert_fold_policy = function(fold_policy)
  if
    fold_policy ~= nil
    and fold_policy ~= "ignore"
    and fold_policy ~= "hop-once"
    and fold_policy ~= "hop-in-and-open"
  then
    error(
      'fold_policy must be "ignore"|"hop-once"|"hop-in-and-open"|nil, but it is: '
        .. tostring(fold_policy)
    )
  end
end

---Options that an api user gives
---@class RH_ApiHopOptions
---@field pattern string
---@field direction? "forward"|"backward"
---@field match_position? "start"|"end" Indicates which end of the match to use.
---@field offset? number Advances final position relatively match_position.
---@field insert_mode_target_side? "left"|"right" side to place the cursor in insert mode.
---@field accept_policy? "from-after-cursor"|"from-cursor"|"any" Indicates whether a potential position should be accepted.
---@field fold_policy? "ignore"|"hop-once"|"hop-in-and-open" Decides how to deal with folds.
---@field count number? count of hops to perform

---Checks and fills empty fields with default values
---@param options RH_ApiHopOptions
---@return RH_HopOptions
M.get_hop_options = function(options)
  if type(options) ~= "table" then
    error("hop options must be a table, but it is: " .. tostring(type(options)))
  end

  assert_pattern(options.pattern)
  assert_direction(options.direction)
  assert_match_position(options.match_position)
  assert_offset(options.offset)
  assert_insert_mode_target_side(options.insert_mode_target_side)
  assert_count(options.count)
  assert_accept_policy(options.accept_policy)
  assert_fold_policy(options.fold_policy)

  local default = {
    direction = "forward",
    match_position = "start",
    offset = 0,
    insert_mode_target_side = "left",
    count = 1,
    accept_policy = "from-after-cursor",
    fold_policy = "hop-once",
  }

  local hop_options = vim.tbl_extend("force", default, options)
  return hop_options
end

return M
