local nw = require("neowords")
local h = require("tests.helpers")

require("tests.custom-asserts").register()

describe("misc", function()
  it("input types must be checked", function()
    local state, error = pcall(nw.get_word_hops, true)
    assert.is.False(state)
    assert.is_not.Nil(error:match("it's a boolean"))
  end)

  it("at least one pattern must be passed", function()
    local state, error = pcall(nw.get_word_hops)
    assert.is.False(state)
    assert.is_not.Nil(error:match("At least one pattern must be passed"))
  end)

  it("error on missed pattern_presets access", function()
    local state, error = pcall(function()
      _ = nw.pattern_presets.unexisting_field
    end)
    assert.is.False(state)
    assert.is_not.Nil(error:match("unexisting_field"))
  end)

  it("should unite several all given patterns together", function()
    h.get_preset("| <a> <b> <a> <b>" , { 1, 0 })()
    local hops = nw.get_word_hops("\\M<a>", "\\M<b>")

    h.perform_through_keymap(hops.forward_start, true)
    assert.cursor_at( 1, 2 )

    h.perform_through_keymap(hops.forward_start, true)
    assert.cursor_at( 1, 6 )
  end)
end)
