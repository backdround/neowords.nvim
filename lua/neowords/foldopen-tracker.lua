local index = 0

---@class NW_FoldopenTracker
---@field has_hor fun(): boolean Whether the foldopen option contains 'hor' value
---@field [string] any private fields

local new = function()
  local tracker = {
    _auto_group_name = "NeowordsFoldopenTracker_" .. tostring(index)
  }
  index = index + 1

  vim.api.nvim_create_augroup(tracker._auto_group_name, { clear = true })
  vim.api.nvim_create_autocmd("OptionSet", {
    pattern = "foldopen",
    group = tracker._auto_group_name,
    callback = function()
      tracker:_update_has_hor()
    end,
  })

  ---@param self NW_FoldopenTracker
  tracker._update_has_hor = function(self)
    local foldopen = vim.opt.foldopen:get()
    self._has_hor = vim.tbl_contains(foldopen, "hor")
  end
  tracker:_update_has_hor()

  tracker.has_hor = function()
    return tracker._has_hor
  end

  return tracker
end

return {
  new = new
}
