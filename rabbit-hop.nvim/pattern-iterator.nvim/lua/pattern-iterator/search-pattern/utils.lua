-- require("../position")
local position = require(({ ... })[1]:gsub("[^.]+%.[^.]+$", "") .. "position")

local M = {}

---Vim search wrapper
---@param pattern string
---@param flags string
---@return PI_Position?
M.vim_search = function(pattern, flags)
  local found_position = nil
  vim.fn.search(pattern, flags, nil, nil, function()
    found_position = position.from_cursor(true)
  end)

  return found_position
end

---Sets vim state for searching.
---@return function A function that restores the initial vim state.
M.prepare_vim_state = function()
  -- Save the current state
  local saved_view = vim.fn.winsaveview()
  local saved_virtualedit =
    vim.api.nvim_get_option_value("virtualedit", { scope = "local" })

  -- Set state
  vim.api.nvim_set_option_value( "virtualedit", "onemore", { scope = "local" })

  -- Return restore function
  return function()
    vim.fn.winrestview(saved_view)
    vim.api.nvim_set_option_value(
      "virtualedit",
      saved_virtualedit,
      { scope = "local" }
    )
  end
end

return M
