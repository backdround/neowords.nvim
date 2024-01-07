local h = require("tests.helpers")
local pattern_iterator = require("pattern-iterator")

require("tests.custom-asserts").register()

describe("pattern-iterator", function()
  before_each(h.get_preset([[
    some text <a>
    some <a> text
    <a> some text
  ]]))

  it("positions", function()
    local iterator = pattern_iterator.new_around("\\M<a>", {
      from_search_position = { 2, 7 }
    })
    assert.position(iterator:start_position(), { 2, 6, false })
    assert.position(iterator:end_position(), { 2, 8, false })
  end)

  describe("creation", function()
    describe("new_around", function()
      it("from a match", function()
        local iterator = pattern_iterator.new_around("\\M<a>", {
          from_search_position = { 2, 7 }
        })
        assert.iterator(iterator, { 2, 6 }, { 2, 8 })
      end)

      it("outside of a match", function()
        local iterator = pattern_iterator.new_around("\\M<a>", {
          from_search_position = { 2, 5 }
        })
        assert.is.Nil(iterator)
      end)
    end)

    describe("new_forward", function()
      it("from a match", function()
        local iterator = pattern_iterator.new_forward("\\M<a>", {
          from_search_position = { 2, 7 }
        })
        assert.iterator(iterator, { 3, 1 }, { 3, 3 })
      end)

      it("outside of a match", function()
        local iterator = pattern_iterator.new_forward("\\M<a>", {
          from_search_position = { 2, 9 }
        })
        assert.iterator(iterator, { 3, 1 }, { 3, 3 })
      end)

      it("there is no match after", function()
        local iterator = pattern_iterator.new_forward("\\M<a>", {
          from_search_position = { 3, 4 }
        })
        assert.is.Nil(iterator)
      end)
    end)

    describe("new_backward", function()
      it("from a match", function()
        local iterator = pattern_iterator.new_backward("\\M<a>", {
          from_search_position = { 2, 7 }
        })
        assert.iterator(iterator, { 1, 11 }, { 1, 13 })
      end)

      it("outside of a match", function()
        local iterator = pattern_iterator.new_backward("\\M<a>", {
          from_search_position = { 2, 5 }
        })
        assert.iterator(iterator, { 1, 11 }, { 1, 13 })
      end)

      it("there is no match before", function()
        local iterator = pattern_iterator.new_backward("\\M<a>", {
          from_search_position = { 1, 10 }
        })
        assert.is.Nil(iterator)
      end)
    end)

    it("without initial search position", function()
      h.set_cursor(2, 7)
      local iterator = pattern_iterator.new_around("\\M<a>")
      assert.iterator(iterator, { 2, 6 }, { 2, 8 })
    end)
  end)

  describe("next()", function()
    it("simple next", function()
      local iterator = pattern_iterator.new_around("\\M<a>", {
        from_search_position = { 2, 7 }
      })
      assert.is.True(iterator:next())
      assert.iterator(iterator, { 3, 1 }, { 3, 3 })
    end)

    it("next with a count", function()
      local iterator = pattern_iterator.new_forward("\\M<a>", {
        from_search_position = { 1, 1 }
      })
      assert.is.True(iterator:next(2))
      assert.iterator(iterator, { 3, 1 }, { 3, 3 })
    end)

    it("next hits the last", function()
      local iterator = pattern_iterator.new_around("\\M<a>", {
        from_search_position = { 3, 1 }
      })
      assert.is.False(iterator:next())
      assert.iterator(iterator, { 3, 1 }, { 3, 3 })
    end)
  end)

  describe("previous()", function()
    it("simple previous", function()
      local iterator = pattern_iterator.new_around("\\M<a>", {
        from_search_position = { 2, 7 }
      })
      assert.is.True(iterator:previous())
      assert.iterator(iterator, { 1, 11 }, { 1, 13 })
    end)

    it("previous with a count", function()
      local iterator = pattern_iterator.new_around("\\M<a>", {
        from_search_position = { 3, 1 }
      })
      assert.is.True(iterator:previous(2))
      assert.iterator(iterator, { 1, 11 }, { 1, 13 })
    end)

    it("previous hits the first", function()
      local iterator = pattern_iterator.new_around("\\M<a>", {
        from_search_position = { 1, 12 }
      })
      assert.is.False(iterator:previous())
      assert.iterator(iterator, { 1, 11 }, { 1, 13 })
    end)
  end)

  describe("pattern == '$'", function()
    it("with n_is_pointable == true", function()
      local iterator = pattern_iterator.new_around("\\v$", {
        from_search_position = { 2, 14 },
        n_is_pointable = true,
      })

      assert.iterator(iterator, { 2, 14 }, { 2, 14 })

      assert.is.True(iterator:next())
      assert.iterator(iterator, { 3, 14 }, { 3, 14 })

      assert.is.False(iterator:next())
      assert.iterator(iterator, { 3, 14 }, { 3, 14 })

      assert.is.True(iterator:previous())
      assert.iterator(iterator, { 2, 14 }, { 2, 14 })

      assert.is.True(iterator:previous())
      assert.iterator(iterator, { 1, 14 }, { 1, 14 })

      assert.is.False(iterator:previous())
      assert.iterator(iterator, { 1, 14 }, { 1, 14 })

      assert.is.True(iterator:next())
      assert.iterator(iterator, { 2, 14 }, { 2, 14 })
    end)

    it("with n_is_pointable == false", function()
      local iterator = pattern_iterator.new_around("\\v$", {
        from_search_position = { 2, 14 },
        n_is_pointable = false,
      })

      assert.iterator(iterator, { 2, 13 }, { 2, 13 })

      assert.is.True(iterator:next())
      assert.iterator(iterator, { 3, 13 }, { 3, 13 })

      assert.is.False(iterator:next())
      assert.iterator(iterator, { 3, 13 }, { 3, 13 })

      assert.is.True(iterator:previous())
      assert.iterator(iterator, { 2, 13 }, { 2, 13 })

      assert.is.True(iterator:previous())
      assert.iterator(iterator, { 1, 13 }, { 1, 13 })

      assert.is.False(iterator:previous())
      assert.iterator(iterator, { 1, 13 }, { 1, 13 })

      assert.is.True(iterator:next())
      assert.iterator(iterator, { 2, 13 }, { 2, 13 })
    end)
  end)

  it("pattern == '^'", function()
    local iterator = pattern_iterator.new_around("\\v^", {
      from_search_position = { 2, 1 },
    })

    assert.iterator(iterator, { 2, 1 }, { 2, 1 })

    assert.is.True(iterator:next())
    assert.iterator(iterator, { 3, 1 }, { 3, 1 })

    assert.is.False(iterator:next())
    assert.iterator(iterator, { 3, 1 }, { 3, 1 })

    assert.is.True(iterator:previous())
    assert.iterator(iterator, { 2, 1 }, { 2, 1 })

    assert.is.True(iterator:previous())
    assert.iterator(iterator, { 1, 1 }, { 1, 1 })

    assert.is.False(iterator:previous())
    assert.iterator(iterator, { 1, 1 }, { 1, 1 })

    assert.is.True(iterator:next())
    assert.iterator(iterator, { 2, 1 }, { 2, 1 })
  end)

  it("pattern == 'a\\na'", function()
    h.get_preset([[
      abba
      abbba
      abba
    ]])()

    local iterator = pattern_iterator.new_around("a\\na", {
      from_search_position = { 1, 4 },
    })

    assert.iterator(iterator, { 1, 4 }, { 2, 1 })

    assert.is.True(iterator:next())
    assert.iterator(iterator, { 2, 5 }, { 3, 1 })

    assert.is.False(iterator:next())
    assert.iterator(iterator, { 2, 5 }, { 3, 1 })

    assert.is.True(iterator:previous())
    assert.iterator(iterator, { 1, 4 }, { 2, 1 })

    assert.is.False(iterator:previous())
    assert.iterator(iterator, { 1, 4 }, { 2, 1 })

    assert.is.True(iterator:next())
    assert.iterator(iterator, { 2, 5 }, { 3, 1 })
  end)

  it("dense matches placement", function()
    h.get_preset("aaaaa")()

    local iterator = pattern_iterator.new_around("\\Ma", {
      from_search_position = { 1, 3 },
    })

    assert.iterator(iterator, { 1, 3 }, { 1, 3 })

    assert.is.True(iterator:next(2))
    assert.iterator(iterator, { 1, 5 }, { 1, 5 })

    assert.is.False(iterator:next())
    assert.iterator(iterator, { 1, 5 }, { 1, 5 })

    assert.is.True(iterator:previous(4))
    assert.iterator(iterator, { 1, 1 }, { 1, 1 })

    assert.is.False(iterator:previous())
    assert.iterator(iterator, { 1, 1 }, { 1, 1 })

    assert.is.True(iterator:next(2))
    assert.iterator(iterator, { 1, 3 }, { 1, 3 })
  end)

  it("non-ascii text", function()
    h.get_preset("некоторые слова тут")()

    local lower_word = "\\v[[:lower:]]+"
    local iterator = pattern_iterator.new_around(lower_word, {
      from_search_position = { 1, 13 },
    })

    assert.iterator(iterator, { 1, 11 }, { 1, 15 })

    assert.is.True(iterator:next())
    assert.iterator(iterator, { 1, 17 }, { 1, 19 })

    assert.is.True(iterator:previous())
    assert.iterator(iterator, { 1, 11 }, { 1, 15 })

    assert.is.True(iterator:previous())
    assert.iterator(iterator, { 1, 1 }, { 1, 9 })
  end)
end)
