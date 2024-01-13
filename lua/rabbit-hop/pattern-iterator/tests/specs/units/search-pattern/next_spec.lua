local h = require("tests.helpers")
local search_pattern = require("pattern-iterator.search-pattern")
local position = require("pattern-iterator.position")

require("tests.custom-asserts").register()

describe("search-pattern.next", function()
  -- The case isn't possible because of vim.fn.search
  -- https://github.com/vim/vim/issues/13755#issuecomment-1869227510
  pending("pattern == 'a$'")
  -- The case isn't possible because of vim.fn.search
  pending("pattern == '(a|$)'")

  it("there is no next match", function()
    h.get_preset("<b> <b> <b>")()

    local from_position = position.from_coordinates(1, 0)
    local match_position = search_pattern.next("\\M<a>", from_position)

    assert.is.Nil(match_position)
  end)

  it("the cursor shouldn't change the position", function()
    h.get_preset("<b> <b> <b>")()

    local from_position = position.from_coordinates(1, 5)
    search_pattern.next("<b>", from_position)

    assert.cursor_at(1, 1)
  end)

  describe("simple pattern", function()
    before_each(h.get_preset("<a> <a> <a>"))
    local pattern = "\\M<a>"

    it("from a position that is before a match", function()
      local from_position = position.from_coordinates(1, 4)
      local match_position = search_pattern.next(pattern, from_position)

      assert.match_position(match_position, { 1, 5 }, { 1, 7 })
    end)

    it("from a position that is at the start of a previous match", function()
      local from_position = position.from_coordinates(1, 1)
      local match_position = search_pattern.next(pattern, from_position)

      assert.match_position(match_position, { 1, 5 }, { 1, 7 })
    end)

    it("from a position that is in the middle of a previous match", function()
      local from_position = position.from_coordinates(1, 2)
      local match_position = search_pattern.next(pattern, from_position)

      assert.match_position(match_position, { 1, 5 }, { 1, 7 })
    end)

    it("from a position that is at the end of a previous match", function()
      local from_position = position.from_coordinates(1, 3)
      local match_position = search_pattern.next(pattern, from_position)

      assert.match_position(match_position, { 1, 5 }, { 1, 7 })
    end)
  end)

  describe("muliline pattern", function()
    before_each(h.get_preset([[
      abba
      abbba
      abba
    ]]))

    describe("pattern == '$'", function()
      it("from a position that is before the match", function()
        local from_position = position.from_coordinates(2, 5)
        local match_position = search_pattern.next("\\v$", from_position)

        assert.match_position(match_position, { 2, 6 }, { 2, 6 })
      end)

      it("from a position that is at the match", function()
        local from_position = position.from_coordinates(1, 5, true)
        local match_position = search_pattern.next("\\v$", from_position)

        assert.match_position(match_position, { 2, 6 }, { 2, 6 })
      end)
    end)

    describe("pattern == '^'", function()
      it("from a position that is before the match", function()
        local from_position = position.from_coordinates(1, 5, true)
        local match_position = search_pattern.next("\\v^", from_position)

        assert.match_position(match_position, { 2, 1 }, { 2, 1 })
      end)

      it("from a position that is on the match", function()
        local from_position = position.from_coordinates(2, 1, true)
        local match_position = search_pattern.next("\\v^", from_position)

        assert.match_position(match_position, { 3, 1 }, { 3, 1 })
      end)
    end)

    describe("pattern == 'a\\na'", function()
      it("from a position that is before the match", function()
        local from_position = position.from_coordinates(1, 3, true)
        local match_position = search_pattern.next("\\va\\na", from_position)

        assert.match_position(match_position, { 1, 4 }, { 2, 1 })
      end)

      it("from a position that is on the match", function()
        local from_position = position.from_coordinates(1, 4, true)
        local match_position = search_pattern.next("\\va\\na", from_position)

        assert.match_position(match_position, { 2, 5 }, { 3, 1 })
      end)
    end)
  end)
end)
