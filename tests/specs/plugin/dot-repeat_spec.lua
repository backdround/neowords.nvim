local rabbit_hop = require("rabbit-hop")
local h = require("tests.helpers")

require("tests.custom-asserts").register()

---Performs the rabbit_hop.hop through a keymap
---@param direction "forward"|"backward"|nil
---@param offset "pre"|"start"|"end"|"post"|nil
---@param pattern string
---@param additional_options table|nil
local hop = function(direction, offset, pattern, additional_options)
  local hop_options = additional_options or {}
  hop_options.direction = direction
  hop_options.offset = offset
  hop_options.pattern = pattern

  h.perform_through_keymap(rabbit_hop.hop, true, hop_options)
end

describe("dot `.` repeat", function()
  before_each(h.get_preset("<a> <a> <a> <a> <a> <a>", { 1, 0 }))
  local pattern = "\\M<a>"

  it("should work", function()
    vim.api.nvim_feedkeys("d", "n", false)
    hop("forward", "pre", pattern)
    assert.buffer("<a> <a> <a> <a> <a>")

    vim.api.nvim_feedkeys(".", "nx", false)
    assert.buffer("<a> <a> <a> <a>")
  end)

  it("should respect old v:count", function()
    vim.api.nvim_feedkeys("2d", "n", false)
    hop("forward", "pre", pattern)
    assert.buffer("<a> <a> <a> <a>")

    vim.api.nvim_feedkeys(".", "nx", false)
    assert.buffer("<a> <a>")
  end)

  it("should choose new v:count over old v:count", function()
    vim.api.nvim_feedkeys("2d", "n", false)
    hop("forward", "pre", pattern)
    assert.buffer("<a> <a> <a> <a>")

    vim.api.nvim_feedkeys("3.", "nx", false)
    assert.buffer("<a>")
  end)

  it("should use last operator-pending v:count hop", function()
    vim.api.nvim_feedkeys("2d", "n", false)
    hop("forward", "pre", pattern)
    assert.buffer("<a> <a> <a> <a>")
    h.set_cursor(1, 0)

    vim.api.nvim_feedkeys("3", "n", false)
    hop("forward", "pre", pattern)
    h.set_cursor(1, 0)

    vim.api.nvim_feedkeys(".", "nx", false)
    assert.buffer("<a> <a>")
  end)
end)
