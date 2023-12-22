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
end)
