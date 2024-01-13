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

  describe("accept_policy", function()
    describe("forward", function()
      it("from-after-cursor accepts only positions after the cursor", function()
        api_helpers.hop(pattern, "forward", "start", {
          accept_policy = "from-after-cursor",
        })
        assert.cursor_at(1, 7)
      end)

      it("from-cursor accepts positions after ar at the cursor", function()
        api_helpers.hop(pattern, "forward", "start", {
          accept_policy = "from-cursor",
        })
        assert.cursor_at(1, 4)
      end)

      it("any accepts any position", function()
        h.set_cursor(1, 5)
        api_helpers.hop(pattern, "forward", "start", {
          accept_policy = "any",
        })
        assert.cursor_at(1, 4)
      end)
    end)

    describe("backward", function()
      it("from-after-cursor accepts only positions before the cursor", function()
        h.set_cursor(1, 5)
        api_helpers.hop(pattern, "backward", "end", {
          accept_policy = "from-after-cursor",
        })
        assert.cursor_at(1, 2)
      end)

      it("from-cursor accepts positions before ar at the cursor", function()
        h.set_cursor(1, 5)
        api_helpers.hop(pattern, "backward", "end", {
          accept_policy = "from-cursor",
        })
        assert.cursor_at(1, 5)
      end)

      it("any accepts any position", function()
        h.set_cursor(1, 4)
        api_helpers.hop(pattern, "backward", "end", {
          accept_policy = "any",
        })
        assert.cursor_at(1, 5)
      end)
    end)
  end)

  describe("fold_policy", function()
    before_each(function()
      h.get_preset([[
        ab ab ab
        ab ab ab
        ab ab ab
        ab ab ab
      ]], { 2, 7 })()
      h.create_fold(2, 3)
    end)

    describe("ignore", function()
      it("from a folded area should hop out", function()
        api_helpers.hop(pattern, "forward", "start", {
          fold_policy = "ignore",
        })
        assert.cursor_at(4, 1)
      end)

      it("from outside a folded area should hop through", function()
        h.set_cursor(1, 7)
        api_helpers.hop(pattern, "forward", "start", {
          fold_policy = "ignore",
        })
        assert.cursor_at(4, 1)
      end)
    end)

    describe("hop-in-and-open", function()
      it("should open if hopped in", function()
        api_helpers.hop(pattern, "forward", "start", {
          fold_policy = "hop-in-and-open",
          count = 1,
        })
        assert.cursor_at(3, 1)
        assert.are.same(-1, vim.fn.foldclosed(3))
      end)

      it("shouldn't open if hopped through", function()
        h.set_cursor(1, 7)
        api_helpers.hop(pattern, "forward", "start", {
          fold_policy = "hop-in-and-open",
          count = 7,
        })
        assert.cursor_at(4, 1)
        assert.are.same(2, vim.fn.foldclosed(2))
      end)
    end)

    describe("hop-once", function()
      describe("forward", function()
        it("should hop on a fold", function()
          h.set_cursor(1, 7)
          api_helpers.hop(pattern, "forward", "start", {
            fold_policy = "hop-once",
          })
          assert.cursor_at(2, 1)
        end)

        it("should count as a match", function()
          h.set_cursor(1, 7)
          api_helpers.hop(pattern, "forward", "start", {
            fold_policy = "hop-once",
            count = 2,
          })
          assert.cursor_at(4, 1)
        end)

        it("shouldn't count as a match when start on", function()
          api_helpers.hop(pattern, "forward", "start", {
            fold_policy = "hop-once",
          })
          assert.cursor_at(4, 1)
        end)
      end)

      describe("backward", function()
        it("should hop on a fold", function()
          h.set_cursor(4, 1)
          api_helpers.hop(pattern, "backward", "start", {
            fold_policy = "hop-once",
          })
          assert.cursor_at(3, 7)
        end)

        it("should count as a match", function()
          h.set_cursor(4, 1)
          api_helpers.hop(pattern, "backward", "start", {
            fold_policy = "hop-once",
            count = 2,
          })
          assert.cursor_at(1, 7)
        end)

        it("shouldn't count as a match when start on", function()
          api_helpers.hop(pattern, "backward", "start", {
            fold_policy = "hop-once",
          })
          assert.cursor_at(1, 7)
        end)
      end)
    end)
  end)
end)
