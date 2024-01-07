---@return boolean represents \n is pointable
local is_n_pointable = function()
  local virtualedit = vim.api.nvim_get_option_value("virtualedit", {})
  if virtualedit == "all" or virtualedit == "onemore" then
    return true
  end

  local current_mode = tostring(vim.fn.mode(true))
  local is_normal_mode = current_mode:find("n") ~= nil

  return not is_normal_mode
end

return {
  is_n_pointable = is_n_pointable,
}
