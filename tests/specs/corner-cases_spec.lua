local nw = require("neowords")
local h = require("tests.helpers")

require("tests.custom-asserts").register()

describe("corner-cases", function()
  it("hop forward_end from the middle of a word", function()
    h.get_preset("several_snake_words", { 1, 3 })()
    local hops = nw.get_word_hops("\\v[[:lower:]]+")

    h.perform_through_keymap(hops.forward_end, true)
    assert.cursor_at(1, 7)
  end)

  local description =
    "hop from the place that doesn't match the start of a word, but is part of a word"
  describe(description, function()
    before_each(h.get_preset([[
      -a-w- a---w -a-w-
    ]], { 1, 9 }))

    local hops = nw.get_word_hops("\\v-@![-[:lower:]]+")

    it("forward_start", function()
      h.perform_through_keymap(hops.forward_start, true)
      assert.cursor_at(1, 14)
    end)

    it("forward_end", function()
      h.perform_through_keymap(hops.forward_end, true)
      assert.cursor_at(1, 11)
    end)

    it("backward_start", function()
      h.perform_through_keymap(hops.backward_start, true)
      assert.cursor_at(1, 7)
    end)

    it("backward_end", function()
      h.perform_through_keymap(hops.backward_end, true)
      assert.cursor_at(1, 5)
    end)
  end)
end)
