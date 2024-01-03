local h = require("tests.helpers")
local search_pattern = require("pattern-iterator.search-pattern")
local position = require("pattern-iterator.position")

require("tests.custom-asserts").register()

describe("search-pattern.current", function()
  -- The case isn't possible because of vim.fn.search
  -- https://github.com/vim/vim/issues/13755#issuecomment-1869227510
  pending("pattern == 'a$'")
  -- The case isn't possible because of vim.fn.search
  pending("pattern == '(a|$)'")

  it("there is no match", function()
    h.get_preset("<b> <b> <b>")()

    local from_position = position.from_coordinates(1, 0)
    local match_position = search_pattern.current("\\M<a>", from_position)

    assert.is.Nil(match_position)
  end)

  describe("simple pattern", function()
    before_each(h.get_preset("<a> <a> <a>"))
    local pattern = "\\M<a>"

    it("from a position that is before a match", function()
      local from_position = position.from_coordinates(1, 3)
      local match_position = search_pattern.current(pattern, from_position)

      assert.is.Nil(match_position)
    end)

    it("the cursor shouldn't change the position", function()
      local from_position = position.from_coordinates(1, 4)
      search_pattern.current(pattern, from_position)

      assert.cursor_at(1, 0)
    end)

    it("from a position that is at the start of a match", function()
      local from_position = position.from_coordinates(1, 4)
      local match_position = search_pattern.current(pattern, from_position)

      assert.match_position(match_position, { 1, 4 }, { 1, 6 })
    end)

    it("from a position that is in the middle of a match", function()
      local from_position = position.from_coordinates(1, 5)
      local match_position = search_pattern.current(pattern, from_position)

      assert.match_position(match_position, { 1, 4 }, { 1, 6 })
    end)

    it("from a position that is at the end of a match", function()
      local from_position = position.from_coordinates(1, 6)
      local match_position = search_pattern.current(pattern, from_position)

      assert.match_position(match_position, { 1, 4 }, { 1, 6 })
    end)

    it("from a position that is after a match", function()
      local from_position = position.from_coordinates(1, 7)
      local match_position = search_pattern.current(pattern, from_position)

      assert.is.Nil(match_position)
    end)
  end)

  describe("pattern == '$'", function()
    before_each(h.get_preset([[
      some
      words
      here
    ]]))
    local pattern = "\\v$"

    it("from a position that is before the match", function()
      local from_position = position.from_coordinates(2, 4, false)
      local match_position = search_pattern.current(pattern, from_position)

      assert.is.Nil(match_position)
    end)

    it("from a position that is after the match", function()
      local from_position = position.from_coordinates(3, 0, false)
      local match_position = search_pattern.current(pattern, from_position)

      assert.is.Nil(match_position)
    end)

    it("from a position that is on the match", function()
      local from_position = position.from_coordinates(2, 5, true)
      local match_position = search_pattern.current(pattern, from_position)

      assert.match_position(match_position, { 2, 5 }, { 2, 5 })
    end)
  end)

  describe("pattern == '^'", function()
    before_each(h.get_preset([[
      some
      words
      here
    ]]))
    local pattern = "\\v^"

    it("from a position that is before the match", function()
      local from_position = position.from_coordinates(1, 4, true)
      local match_position = search_pattern.current(pattern, from_position)

      assert.is.Nil(match_position)
    end)

    it("from a position that is after the match", function()
      local from_position = position.from_coordinates(2, 1, true)
      local match_position = search_pattern.current(pattern, from_position)

      assert.is.Nil(match_position)
    end)

    it("from a position that is on the match", function()
      local from_position = position.from_coordinates(2, 0, true)
      local match_position = search_pattern.current(pattern, from_position)

      assert.match_position(match_position, { 2, 0 }, { 2, 0 })
    end)
  end)

  describe("pattern == '^a'", function()
    before_each(h.get_preset([[
      abbb
      abbbb
      abbb
    ]]))
    local pattern = "\\v^a"

    it("from a position that is before the match", function()
      local from_position = position.from_coordinates(1, 4, true)
      local match_position = search_pattern.current(pattern, from_position)

      assert.is.Nil(match_position)
    end)

    it("from a position that is on the match", function()
      local from_position = position.from_coordinates(2, 0, true)
      local match_position = search_pattern.current(pattern, from_position)

      assert.match_position(match_position, { 2, 0 }, { 2, 0 })
    end)

    it("from a position that is after the match", function()
      local from_position = position.from_coordinates(2, 1, true)
      local match_position = search_pattern.current(pattern, from_position)

      assert.is.Nil(match_position)
    end)
  end)

  describe("pattern == 'a\\na'", function()
    before_each(h.get_preset([[
      abba
      abbba
      abba
    ]]))
    local pattern = "\\va\\na"

    it("from a position that is before the match", function()
      local from_position = position.from_coordinates(2, 3, true)
      local match_position = search_pattern.current(pattern, from_position)

      assert.is.Nil(match_position)
    end)

    it("from a position that is at the start of the match", function()
      local from_position = position.from_coordinates(2, 4, true)
      local match_position = search_pattern.current(pattern, from_position)

      assert.match_position(match_position, { 2, 4 }, { 3, 0 })
    end)

    it("from a position that is in the middle of the match", function()
      local from_position = position.from_coordinates(2, 5, true)
      local match_position = search_pattern.current(pattern, from_position)

      assert.match_position(match_position, { 2, 4 }, { 3, 0 })
    end)

    it("from a position that is at the end of the match", function()
      local from_position = position.from_coordinates(3, 0, true)
      local match_position = search_pattern.current(pattern, from_position)

      assert.match_position(match_position, { 2, 4 }, { 3, 0 })
    end)

    it("from a position that is after the match", function()
      local from_position = position.from_coordinates(3, 1, true)
      local match_position = search_pattern.current(pattern, from_position)

      assert.is.Nil(match_position)
    end)
  end)
end)
