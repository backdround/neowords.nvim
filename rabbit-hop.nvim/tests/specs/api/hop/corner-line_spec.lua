local api_helpers = require("tests.api-helpers")
local h = require("tests.helpers")

require("tests.custom-asserts").register()

describe("corner-line-hop", function()
  before_each(h.get_preset([[
    some words <a>
    <b> | <b>
    <c> other words
  ]], { 2, 4 }))

  describe("normal-mode", function()
    it("pre-forward", function()
      api_helpers.hop("forward", "pre", "<c>")
      assert.cursor_at(2, 8)
    end)

    it("post-forward", function()
      api_helpers.hop("forward", "post", "<b>")
      assert.cursor_at(3, 0)
    end)

    it("pre-backward", function()
      api_helpers.hop("backward", "pre", "<a>")
      assert.cursor_at(2, 0)
    end)

    it("post-backward", function()
      api_helpers.hop("backward", "post", "<b>")
      assert.cursor_at(1, 13)
    end)
  end)

  describe("visual-mode", function()
    before_each(h.trigger_visual)

    it("pre-forward", function()
      api_helpers.hop("forward", "pre", "<c>")
      h.reset_mode()
      assert.last_selected_region({ 2, 4 }, { 2, 9 })
    end)

    it("post-forward", function()
      api_helpers.hop("forward", "post", "<b>")
      h.reset_mode()
      assert.last_selected_region({ 2, 4 }, { 2, 9 })
    end)

    it("pre-backward", function()
      api_helpers.hop("backward", "pre", "<a>")
      h.reset_mode()
      assert.last_selected_region({1, 14}, { 2, 4 })
    end)

    it("post-backward", function()
      api_helpers.hop("backward", "post", "<b>")
      h.reset_mode()
      assert.last_selected_region({ 1, 14 }, { 2, 4 })
    end)
  end)

  describe("operator-pending-mode", function()
    before_each(h.trigger_delete)

    it("pre-forward", function()
      api_helpers.hop("forward", "pre", "<c>")
      h.reset_mode()
      assert.buffer([[
        some words <a>
        <b> <c> other words
      ]])
    end)

    it("post-forward", function()
      api_helpers.hop("forward", "post", "<b>")
      h.reset_mode()
      assert.buffer([[
        some words <a>
        <b> <c> other words
      ]])
    end)

    it("pre-backward", function()
      api_helpers.hop("backward", "pre", "<a>")
      h.reset_mode()
      assert.buffer([[
        some words <a>| <b>
        <c> other words
      ]])
    end)

    it("post-backward", function()
      api_helpers.hop("backward", "post", "<b>")
      h.reset_mode()
      assert.buffer([[
        some words <a>| <b>
        <c> other words
      ]])
    end)
  end)
end)
