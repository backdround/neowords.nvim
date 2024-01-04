local nw = require("neowords")
local h = require("tests.helpers")

require("tests.custom-asserts").register()

describe("count", function()
  before_each(h.get_preset("<a> <b> | <a> <b>", { 1, 9 }))

  local hops = nw.get_word_hops("\\M<a>", "\\M<b>")

  it("forward_start", function()
    h.feedkeys("2", false)
    h.perform_through_keymap(hops.forward_start, true)
    assert.cursor_at(1, 15)
  end)

  it("forward_end", function()
    h.feedkeys("2", false)
    h.perform_through_keymap(hops.forward_end, true)
    assert.cursor_at(1, 17)
  end)

  it("backward_start", function()
    h.feedkeys("2", false)
    h.perform_through_keymap(hops.backward_start, true)
    assert.cursor_at(1, 1)
  end)

  it("backward_end", function()
    h.feedkeys("2", false)
    h.perform_through_keymap(hops.backward_end, true)
    assert.cursor_at(1, 3)
  end)
end)
