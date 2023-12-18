------------------------------------------------------------
-- Utility functions
local function system(command, description)
  local ok, result = pcall(vim.fn.system, command)

  if not ok or vim.v.shell_error ~= 0 then
    local err = result:gsub("Vim:E[0-9]+: ", "")
    error("Unable to " .. description .. ": " .. err, 2)
  end

  return result
end

local function get_project_root()
  local get_git_root_command = { "git", "rev-parse", "--show-toplevel" }
  local root = system(get_git_root_command, "get git root")
  root = root:gsub("\n$", "")
  return root
end

local function get_cache_path()
  local project_name = vim.fn.fnamemodify(get_project_root(), ":t")
  local std_cache_path = vim.fn.stdpath("cache")
  local cache_path = string.format("%s/%s-test", std_cache_path, project_name)

  if not vim.loop.fs_stat(cache_path) then
    vim.fn.mkdir(cache_path, "p")
  end

  return cache_path
end

local function install_plugin(plugin)
  local name = plugin:match(".*/(.*)")
  local plugin_root = get_cache_path() .. "/pack/deps/start/" .. name

  if vim.loop.fs_stat(plugin_root) then
    return
  end

  print("Installing " .. plugin .. "\n")
  local clone_command = {
    "git",
    "clone",
    "--depth=1",
    "https://github.com/" .. plugin .. ".git",
    plugin_root,
  }
  system(clone_command, "clone " .. plugin)
  print("Plugin " .. plugin .. " has been installed" .. "\n")
end

------------------------------------------------------------
-- Init
local function init()
  vim.opt.runtimepath = vim.env.VIMRUNTIME
  vim.opt.swapfile = false
  vim.opt.backup = false

  local project_root = get_project_root()
  vim.opt.runtimepath:append(project_root)
  vim.opt.packpath:append(get_cache_path())
  install_plugin("nvim-lua/plenary.nvim")
end

local ok, err = pcall(init)
if not ok then
  print(err .. "\n")
  os.exit(1)
end
