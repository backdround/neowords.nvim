local nw = require("neowords")
local h = require("tests.helpers")

require("tests.custom-asserts").register()

describe("base hops", function()
  before_each(h.get_preset([[
    words <a_pattern> words
    |
    words <a_pattern> words
  ]], { 2, 1 }))

  local hops = nw.get_word_hops("\\M<a_pattern>")

  describe("normal", function()
    it("forward_start", function()
      h.perform_through_keymap(hops.forward_start, true)
      assert.cursor_at(3, 6)
    end)

    it("forward_end", function()
      h.perform_through_keymap(hops.forward_end, true)
      assert.cursor_at(3, 16)
    end)

    it("backward_start", function()
      h.perform_through_keymap(hops.backward_start, true)
      assert.cursor_at(1, 6)
    end)

    it("backward_end", function()
      h.perform_through_keymap(hops.backward_end, true)
      assert.cursor_at(1, 16)
    end)
  end)

  describe("visual", function()
    before_each(h.trigger_visual)

    it("forward_start", function()
      h.perform_through_keymap(hops.forward_start, true)
      h.reset_mode()
      assert.last_selected_region({ 2, 0 }, { 3, 6 })
    end)

    it("forward_end", function()
      h.perform_through_keymap(hops.forward_end, true)
      h.reset_mode()
      assert.last_selected_region({ 2, 0 }, { 3, 16 })
    end)

    it("backward_start", function()
      h.perform_through_keymap(hops.backward_start, true)
      h.reset_mode()
      assert.last_selected_region({ 1, 6 }, { 2, 0 })
    end)

    it("backward_end", function()
      h.perform_through_keymap(hops.backward_end, true)
      h.reset_mode()
      assert.last_selected_region({ 1, 16 }, { 2, 0 })
    end)
  end)

  describe("operator-pending", function()
    before_each(h.trigger_delete)

    it("forward_start", function()
      h.perform_through_keymap(hops.forward_start, true)
      assert.buffer([[
        words <a_pattern> words
        <a_pattern> words
      ]])
    end)

    it("forward_end", function()
      h.perform_through_keymap(hops.forward_end, true)
      assert.buffer([[
        words <a_pattern> words
         words
      ]])
    end)

    it("backward_start", function()
      h.perform_through_keymap(hops.backward_start, true)
      assert.buffer([[
        words |
        words <a_pattern> words
      ]])
    end)

    it("backward_end", function()
      h.perform_through_keymap(hops.backward_end, true)
      assert.buffer([[
        words <a_pattern>|
        words <a_pattern> words
      ]])
    end)
  end)

  describe("insert", function()
    before_each(function()
      h.feedkeys("i", false)
    end)

    it("forward_start", function()
      h.perform_through_keymap(hops.forward_start, true)
      assert.cursor_at(3, 5)
    end)

    it("forward_end", function()
      h.perform_through_keymap(hops.forward_end, true)
      assert.cursor_at(3, 16)
    end)

    it("backward_start", function()
      h.perform_through_keymap(hops.backward_start, true)
      assert.cursor_at(1, 5)
    end)

    it("backward_end", function()
      h.perform_through_keymap(hops.backward_end, true)
      assert.cursor_at(1, 16)
    end)
  end)
end)
