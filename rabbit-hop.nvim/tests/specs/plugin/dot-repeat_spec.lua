local rabbit_hop = require("rabbit-hop")
local h = require("tests.helpers")

require("tests.custom-asserts").register()

---Performs a forward hop to a position before a match through a keymap.
---@param pattern string
local hop_before_match = function(pattern)
  h.perform_through_keymap(rabbit_hop.hop, true, {
    direction = "forward",
    match_position = "start",
    offset = -1,
    pattern = pattern,
  })
end

describe("dot `.` repeat", function()
  before_each(h.get_preset("<a> <a> <a> <a> <a> <a>", { 1, 1 }))
  local pattern = "\\M<a>"

  it("should work", function()
    vim.api.nvim_feedkeys("d", "n", false)
    hop_before_match(pattern)
    assert.buffer("<a> <a> <a> <a> <a>")

    vim.api.nvim_feedkeys(".", "nx", false)
    assert.buffer("<a> <a> <a> <a>")
  end)

  it("should respect old v:count", function()
    vim.api.nvim_feedkeys("2d", "n", false)
    hop_before_match(pattern)
    assert.buffer("<a> <a> <a> <a>")

    vim.api.nvim_feedkeys(".", "nx", false)
    assert.buffer("<a> <a>")
  end)

  it("should choose new v:count over old v:count", function()
    vim.api.nvim_feedkeys("2d", "n", false)
    hop_before_match(pattern)
    assert.buffer("<a> <a> <a> <a>")

    vim.api.nvim_feedkeys("3.", "nx", false)
    assert.buffer("<a>")
  end)

  it("should use last operator-pending v:count hop", function()
    vim.api.nvim_feedkeys("2d", "n", false)
    hop_before_match(pattern)
    assert.buffer("<a> <a> <a> <a>")
    h.set_cursor(1, 1)

    vim.api.nvim_feedkeys("3", "n", false)
    hop_before_match(pattern)
    h.set_cursor(1, 1)

    vim.api.nvim_feedkeys(".", "nx", false)
    assert.buffer("<a> <a>")
  end)
end)
