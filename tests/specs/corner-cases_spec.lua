local nw = require("neowords")
local h = require("tests.helpers")

require("tests.custom-asserts").register()

describe("corner-cases", function()
  it("hop forward_end from the middle of a word", function()
    h.get_preset("several_snake_words", { 1, 2 })()
    local hops = nw.get_word_hops("\\v[[:lower:]]+")

    h.perform_through_keymap(hops.forward_end, true)
    assert.cursor_at(1, 6)
  end)

  local description =
    "hop from the place that doesn't match the start of a word, but is part of a word"
  describe(description, function()
    before_each(h.get_preset([[
      -a-w- a---w -a-w-
    ]], { 1, 8 }))

    local hops = nw.get_word_hops("\\v-@![-[:lower:]]+")

    it("forward_start", function()
      h.perform_through_keymap(hops.forward_start, true)
      assert.cursor_at(1, 13)
    end)

    it("forward_end", function()
      h.perform_through_keymap(hops.forward_end, true)
      assert.cursor_at(1, 10)
    end)

    it("backward_start", function()
      h.perform_through_keymap(hops.backward_start, true)
      assert.cursor_at(1, 6)
    end)

    it("backward_end", function()
      h.perform_through_keymap(hops.backward_end, true)
      assert.cursor_at(1, 4)
    end)
  end)
end)
