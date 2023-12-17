local api_helpers = require("tests.api-helpers")
local h = require("tests.helpers")

require("tests.custom-asserts").register()

describe("user-options", function()
  before_each(h.get_preset([[
    aa bb aa bb aa bb
  ]], { 1, 0 }))

  it('"direction" should be "forward" by default', function()
    api_helpers.hop(nil, "start", "aa")
    assert.cursor_at(1, 6)
  end)

  it('"offset" should be "start" by default', function()
    api_helpers.hop("forward", nil, "aa")
    assert.cursor_at(1, 6)
  end)

  it('"insert_mode_target_side" should be "left" by default', function()
    h.trigger_insert()
    api_helpers.hop("forward", "start", "bb", { insert_mode_target_side = nil })
    assert.cursor_at(1, 2)
  end)

  it('"insert_mode_target_side" should shift position if "right"', function()
    h.trigger_insert()
    api_helpers.hop(
      "forward",
      "start",
      "bb",
      { insert_mode_target_side = "right" }
    )
    assert.cursor_at(1, 3)
  end)
end)
