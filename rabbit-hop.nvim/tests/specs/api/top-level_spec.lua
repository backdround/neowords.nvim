local rabbit_hop_api = require("rabbit-hop.api")
local h = require("tests.helpers")

require("tests.custom-asserts").register()

local preset_hop_options1 = {
  direction = "forward",
  offset = "start",
  pattern = "aa",
  insert_mode_target_side = "left",
  count = 1,
}

local preset_hop_options2 = {
  direction = "forward",
  offset = "start",
  pattern = "bb",
  insert_mode_target_side = "right",
  count = 2,
}

describe("top-level", function()
  before_each(function()
    h.get_preset("aa bb aa bb aa bb", { 1, 0 })()
    rabbit_hop_api.reset_state()
  end)

  it("reset_state() should reset state", function()
    h.perform_through_keymap(rabbit_hop_api.hop, true, preset_hop_options1)
    rabbit_hop_api.reset_state()
    assert.is.Nil(rabbit_hop_api.get_last_hop_options())
    assert.is.Nil(rabbit_hop_api.get_last_operator_pending_hop_options())
  end)

  it("get_last_hop_options should work", function()
    h.perform_through_keymap(rabbit_hop_api.hop, true, preset_hop_options1)
    local last_hop_options = rabbit_hop_api.get_last_hop_options()
    assert.are.same(preset_hop_options1, last_hop_options)
  end)

  it("get_last_operator_pending_hop_options should work", function()
    h.feedkeys("d", false)
    h.perform_through_keymap(rabbit_hop_api.hop, true, preset_hop_options1)
    h.perform_through_keymap(rabbit_hop_api.hop, true, preset_hop_options2)
    local last_operator_pending_hop_options =
      rabbit_hop_api.get_last_operator_pending_hop_options()
    assert.are.same(preset_hop_options1, last_operator_pending_hop_options)
  end)

  it("cache_options == false shouldn't save options", function()
    local cache_options = false
    h.perform_through_keymap(
      rabbit_hop_api.hop,
      true,
      preset_hop_options1,
      cache_options
    )

    local last_hop_options = rabbit_hop_api.get_last_hop_options()
    assert.is.Nil(last_hop_options)
  end)
end)
