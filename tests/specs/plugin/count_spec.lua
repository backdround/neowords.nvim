local rabbit_hop = require("rabbit-hop")
local h = require("tests.helpers")

require("tests.custom-asserts").register()

describe("v:count", function()
  before_each(h.get_preset([[
    <a> <a> <a> <a> <a>
  ]], { 1, 1 }))
  local pattern = "\\M<a>"

  it("should be respected during hop", function()
    h.feedkeys("3", false)
    h.perform_through_keymap(rabbit_hop.hop, true, {
      direction = "forward",
      match_position = "start",
      pattern = pattern,
    })
    assert.cursor_at(1, 13)
  end)

  it("should stuck at the last match if v:count is too big", function()
      h.feedkeys("22", false)
      h.perform_through_keymap(rabbit_hop.hop, true, {
        direction = "forward",
        match_position = "start",
        pattern = pattern,
      })
      assert.cursor_at(1, 17)
    end
  )
end)
