local api_helpers = require("tests.api-helpers")
local h = require("tests.helpers")
local rabbit_hop_api = require("rabbit-hop.api")

require("tests.custom-asserts").register()

describe("misc", function()
  before_each(h.get_preset([[
    ab ab | bc bc
    ab ab
  ]], { 1, 6 }))

  describe("should work in operator-pending mode after", function()
    it("linewise visual selection", function()
      h.feedkeys("V<esc>", true)

      h.trigger_delete()
      api_helpers.hop("forward", "pre", "a")

      assert.buffer("ab ab ab ab")
    end)

    it("charwise visual selection", function()
      h.feedkeys("v<esc>", true)

      h.trigger_delete()
      api_helpers.hop("forward", "pre", "a")

      assert.buffer("ab ab ab ab")
    end)

    it("blockwise visual selection", function()
      h.feedkeys("<C-v><esc>", true)

      h.trigger_delete()
      api_helpers.hop("forward", "pre", "a")

      assert.buffer("ab ab ab ab")
    end)

    it("none visual selection", function()
      h.trigger_delete()
      api_helpers.hop("forward", "pre", "a")

      assert.buffer("ab ab ab ab")
    end)
  end)

  describe("should work properly with 'selection' == 'exclusive'", function()
    before_each(function()
      vim.go.selection = "exclusive"
    end)

    it("during backward hop", function()
      h.trigger_visual()
      h.perform_through_keymap(rabbit_hop_api.hop, false, {
        direction = "backward",
        offset = "start",
        pattern = "ab",
      })
      h.feedkeys("d", true)

      assert.buffer([[
        ab | bc bc
        ab ab
      ]])
    end)

    it("during forward hop", function()
      h.trigger_visual()
      h.perform_through_keymap(rabbit_hop_api.hop, false, {
        direction = "forward",
        offset = "pre",
        pattern = "bc"
      })
      h.feedkeys("d", true)

      assert.buffer([[
        ab ab bc bc
        ab ab
      ]])
    end)

    it("during forward hop to a new line", function()
      h.trigger_visual()
      h.perform_through_keymap(rabbit_hop_api.hop, false, {
        direction = "forward",
        offset = "post",
        pattern = "bc",
        count = 2,
      })
      h.feedkeys("d", true)

      assert.buffer([[
        ab ab ab ab
      ]])
    end)
  end)
end)
