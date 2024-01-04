local rabbit_hop = require("rabbit-hop")
local h = require("tests.helpers")

require("tests.custom-asserts").register()

describe("basic", function()
  before_each(h.get_preset("aa aa aa aa aa", { 1, 6 }))
  local pattern = "\\Maa"

  it("no match", function()
    local performed = nil
    h.perform_through_keymap(function()
      performed = rabbit_hop.hop({
        pattern = "aaa",
        direction = "forward",
        match_position = "start",
      })
    end, true)
    assert.is.False(performed)
    assert.cursor_at(1, 6)
  end)

  it("there is a match", function()
    local performed = nil
    h.perform_through_keymap(function()
      performed = rabbit_hop.hop({
        pattern = "aa",
        direction = "forward",
        match_position = "start",
      })
    end, true)
    assert.is.True(performed)
    assert.cursor_at(1, 9)
  end)

  it("normal hop with options", function()
    h.perform_through_keymap(rabbit_hop.hop, true, {
      pattern = pattern,
      direction = "backward",
      match_position = "end",
      offset = -1,
    })
    assert.cursor_at(1, 3)
  end)

  it("insert hop with options", function()
    h.trigger_insert()
    h.perform_through_keymap(rabbit_hop.hop, true, {
      pattern = pattern,
      direction = "backward",
      match_position = "end",
      offset = -1,
      insert_mode_target_side = "right",
    })
    h.reset_mode()
    assert.cursor_at(1, 3)
  end)
end)
