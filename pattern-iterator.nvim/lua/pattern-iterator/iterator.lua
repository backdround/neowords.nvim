local search_pattern = require(({ ... })[1]:gsub("[^.]+$", "") .. "search-pattern")

---Pattern iterator represents positions of the current match.
---@class PI_Iterator
---@field start_position PI_Position Start of the current match
---@field end_position PI_Position End of the current match
---@field _pattern string
---@field _current_match PI_Match
---@field _n_is_pointable boolean

---@param pattern string
---@param current_match PI_Match
---@param n_is_pointable boolean positions can point to a \n.
---@return PI_Iterator
local new = function(pattern, current_match, n_is_pointable)
  local i = {
    _pattern = pattern,
    _current_match = current_match,
    _n_is_pointable = n_is_pointable,
  }

  ---Returns the start position of the match
  ---@param self PI_Iterator
  ---@return PI_Position
  i.start_position = function(self)
    local p = vim.deepcopy(self._current_match.start_position)
    p:set_n_is_pointable(self._n_is_pointable)
    return p
  end

  ---Returns the end position of the match
  ---@param self PI_Iterator
  ---@return PI_Position
  i.end_position = function(self)
    local p = vim.deepcopy(self._current_match.end_position)
    p:set_n_is_pointable(self._n_is_pointable)
    return p
  end

  ---@param self PI_Iterator
  ---@param count? number count of matches to advance
  ---@return boolean performed without hitting the last match
  i.next = function(self, count)
    count = count or 1

    for _ = 1, count do
      local next_match =
        search_pattern.next(self._pattern, self._current_match.end_position)

      if next_match == nil then
        return false
      end

      self._current_match = next_match
    end

    return true
  end

  ---@param self PI_Iterator
  ---@param count? number count of matches to advance
  ---@return boolean performed without hitting the fisrt match
  i.previous = function(self, count)
    count = count or 1

    for _ = 1, count do
      local previous_match =
        search_pattern.previous(self._pattern, self._current_match.end_position)

      if previous_match == nil then
        return false
      end

      self._current_match = previous_match
    end

    return true
  end

  return i
end

return {
  new = new
}
