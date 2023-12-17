local rabbit_hop = require("rabbit-hop")
local h = require("tests.helpers")

require("tests.custom-asserts").register()

describe("v:count", function()
  before_each(h.get_preset([[
    <a> <a> <a> <a> <a>
  ]], { 1, 0 }))
  local pattern = "\\M<a>"

  it("should be respected during hop", function()
    h.feedkeys("3", false)
    h.perform_through_keymap(rabbit_hop.hop, true, {
      direction = "forward",
      offset = "start",
      pattern = pattern,
    })
    assert.cursor_at(1, 12)
  end)

  it(
    "should be taken as a maximal possible count if v:count is too big",
    function()
      h.feedkeys("22", false)
      h.perform_through_keymap(rabbit_hop.hop, true, {
        direction = "forward",
        offset = "start",
        pattern = pattern,
      })
      assert.cursor_at(1, 16)
    end
  )
end)
