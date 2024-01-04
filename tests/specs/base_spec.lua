local nw = require("neowords")
local h = require("tests.helpers")

require("tests.custom-asserts").register()

describe("base hops", function()
  before_each(h.get_preset([[
    words <a_pattern> words
    |
    words <a_pattern> words
  ]], { 2, 2 }))

  local hops = nw.get_word_hops("\\M<a_pattern>")

  describe("normal", function()
    it("forward_start", function()
      h.perform_through_keymap(hops.forward_start, true)
      assert.cursor_at(3, 7)
    end)

    it("forward_end", function()
      h.perform_through_keymap(hops.forward_end, true)
      assert.cursor_at(3, 17)
    end)

    it("backward_start", function()
      h.perform_through_keymap(hops.backward_start, true)
      assert.cursor_at(1, 7)
    end)

    it("backward_end", function()
      h.perform_through_keymap(hops.backward_end, true)
      assert.cursor_at(1, 17)
    end)
  end)

  describe("visual", function()
    before_each(h.trigger_visual)

    it("forward_start", function()
      h.perform_through_keymap(hops.forward_start, true)
      h.reset_mode()
      assert.last_selected_region({ 2, 1 }, { 3, 7 })
    end)

    it("forward_end", function()
      h.perform_through_keymap(hops.forward_end, true)
      h.reset_mode()
      assert.last_selected_region({ 2, 1 }, { 3, 17 })
    end)

    it("backward_start", function()
      h.perform_through_keymap(hops.backward_start, true)
      h.reset_mode()
      assert.last_selected_region({ 1, 7 }, { 2, 1 })
    end)

    it("backward_end", function()
      h.perform_through_keymap(hops.backward_end, true)
      h.reset_mode()
      assert.last_selected_region({ 1, 17 }, { 2, 1 })
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
      assert.cursor_at(3, 6)
    end)

    it("forward_end", function()
      h.perform_through_keymap(hops.forward_end, true)
      assert.cursor_at(3, 17)
    end)

    it("backward_start", function()
      h.perform_through_keymap(hops.backward_start, true)
      assert.cursor_at(1, 6)
    end)

    it("backward_end", function()
      h.perform_through_keymap(hops.backward_end, true)
      assert.cursor_at(1, 17)
    end)
  end)
end)
