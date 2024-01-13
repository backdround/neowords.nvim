---@class RH_PositionChecker
---@field is_suitable fun(): boolean

---@param direction "forward"|"backward"
---@param accept_policy "from-after-cursor"|"from-cursor"|"any" Indicates whether a potential position should be accepted.
---@param fold_policy "ignore"|"hop-once"|"hop-in-and-open" Decides how to deal with folds.
---@return RH_PositionChecker
local new = function(direction, accept_policy, fold_policy)
  local checker = {
    _direction = direction,
    _accept_policy = accept_policy,
    _fold_policy = fold_policy,
  }

  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
  checker._cursor_fold_start = vim.fn.foldclosed(cursor_line)
  checker._cursor_fold_end = vim.fn.foldclosedend(cursor_line)

  ---@param self table
  ---@param position PI_Position
  local accept_policy_check = function(self, position)
    if self._direction == "forward" then
      if self._accept_policy == "from-after-cursor" then
        return position:after_cursor()
      elseif self._accept_policy == "from-cursor" then
        return position:after_cursor() or position:on_cursor()
      elseif self._accept_policy == "any" then
        return true
      end
      error("Shouldn't be attainable")
    end

    if self._accept_policy == "from-after-cursor" then
      return position:before_cursor()
    elseif self._accept_policy == "from-cursor" then
      return position:before_cursor() or position:on_cursor()
    elseif self._accept_policy == "any" then
      return true
    end
    error("Shouldn't be attainable")
  end

  ---@param self table
  ---@param position PI_Position
  local check_hop_once_fold_downward = function(self, position)
    local fold_end = vim.fn.foldclosedend(position.line)
    if fold_end == -1 then
      return true
    end

    if fold_end == self._cursor_fold_end then
      return false
    end

    if fold_end == self._last_fold_end then
      return false
    end

    self._last_fold_end = fold_end
    return true
  end

  ---@param self table
  ---@param position PI_Position
  local check_hop_once_fold_upward = function(self, position)
    local fold_start = vim.fn.foldclosed(position.line)
    if fold_start == -1 then
      return true
    end

    if fold_start == self._cursor_fold_start then
      return false
    end

    if fold_start == self._last_fold_start then
      return false
    end

    self._last_fold_start = fold_start
    return true
  end

  ---@param self table
  ---@param position PI_Position
  local fold_policy_check = function(self, position)
    if self._fold_policy == "ignore" then
      return vim.fn.foldclosed(position.line) == -1
    elseif self._fold_policy == "hop-in-and-open" then
      return true
    elseif self._fold_policy == "hop-once" and self._direction == "forward" then
      return check_hop_once_fold_downward(self, position)
    elseif self._fold_policy == "hop-once" and self._direction == "backward" then
      return check_hop_once_fold_upward(self, position)
    end
    error("Shouldn't be attainable")
  end

  ---@param self RH_PositionChecker
  ---@param position PI_Position
  checker.is_suitable = function(self, position)
    return accept_policy_check(self, position)
      and fold_policy_check(self, position)
  end

  return checker
end

return {
  new = new
}
