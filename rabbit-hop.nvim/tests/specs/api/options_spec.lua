local api_helpers = require("tests.api-helpers")
local h = require("tests.helpers")

require("tests.custom-asserts").register()

describe("main", function()
  before_each(h.get_preset([[
    ab ab ab
    ab ab ab
  ]], { 1, 4 }))
  local pattern = "\\Mab"

  it("default options", function()
    api_helpers.hop(pattern)
    assert.cursor_at(1, 7)
  end)

  describe("direction", function()
    it("should work if direction == 'forward'", function()
      api_helpers.hop(pattern, "forward", "start")
      assert.cursor_at(1, 7)
    end)

    it("should work if direction == 'backward'", function()
      api_helpers.hop(pattern, "backward", "start")
      assert.cursor_at(1, 1)
    end)
  end)

  describe("match_position", function()
    it("should work if match_position == 'start'", function()
      api_helpers.hop(pattern, "forward", "start")
      assert.cursor_at(1, 7)
    end)

    it("should work if match_position == 'end'", function()
      api_helpers.hop(pattern, "forward", "end")
      assert.cursor_at(1, 5)
    end)
  end)

  describe("offset", function()
    it("should work if offset = 0", function()
      api_helpers.hop(pattern, "forward", "start", {
        offset = 0,
      })
      assert.cursor_at(1, 7)
    end)

    it("should work with match_position == 'end'", function()
      api_helpers.hop(pattern, "forward", "end", {
        offset = 1,
      })
      assert.cursor_at(1, 6)
    end)

    describe("forward", function()
      it("should work if offset = 1", function()
        api_helpers.hop(pattern, "forward", "start", {
          offset = 1,
        })
        assert.cursor_at(1, 5)
      end)

      it("should work if offset = 2", function()
        api_helpers.hop(pattern, "forward", "start", {
          offset = 2,
        })
        assert.cursor_at(1, 6)
      end)
    end)

    describe("backward", function()
      it("should work if offset = -1", function()
        api_helpers.hop(pattern, "forward", "start", {
          offset = -1,
        })
        assert.cursor_at(1, 6)
      end)

      it("should work if offset = -2", function()
        api_helpers.hop(pattern, "forward", "start", {
          offset = -2,
        })
        assert.cursor_at(1, 5)
      end)
    end)
  end)

  describe("insert_mode_target_side", function()
    it("should be 'left' by default", function()
      h.trigger_insert()
      api_helpers.hop("ab", "forward", "start", {
        insert_mode_target_side = nil
      })
      assert.cursor_at(1, 6)
    end)

    it("should work if insert_mode_target_side == 'left'", function()
      h.trigger_insert()
      api_helpers.hop("ab", "forward", "start", {
        insert_mode_target_side = "right"
      })
      assert.cursor_at(1, 4)
    end)
  end)

  describe("count", function()
    it("should be respected during hop", function()
      api_helpers.hop(pattern, "forward", "start", {
        count = 3,
      })
      assert.cursor_at(2, 4)
    end)

    it("should stuck at the last match if if count is too big", function()
      api_helpers.hop(pattern, "forward", "start", {
        count = 22,
      })
      assert.cursor_at(2, 7)
    end)
  end)
end)
