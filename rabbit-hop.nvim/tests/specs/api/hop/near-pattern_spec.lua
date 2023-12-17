local api_helpers = require("tests.api-helpers")
local h = require("tests.helpers")

require("tests.custom-asserts").register()

local pattern = "\\M<a>"
describe("near-pattern-hop", function()
  describe("forward", function()
    it("pre from a pattern", function()
      h.get_preset("<a> <a>", { 1, 0 })()
      api_helpers.hop("forward", "pre", pattern)
      assert.cursor_at(1, 3)
    end)

    it("pre from a pre pattern", function()
      h.get_preset("|<a> <a>", { 1, 0 })()
      api_helpers.hop("forward", "pre", pattern)
      assert.cursor_at(1, 4)
    end)

    it("start from a pattern", function()
      h.get_preset("<a> <a>", { 1, 0 })()
      api_helpers.hop("forward", "start", pattern)
      assert.cursor_at(1, 4)
    end)

    it("end from a pattern", function()
      h.get_preset("aaa", { 1, 0 })()
      api_helpers.hop("forward", "end", "a")
      assert.cursor_at(1, 1)
    end)

    it("post from a pattern", function()
      h.get_preset("aaa", { 1, 0 })()
      api_helpers.hop("forward", "post", "a")
      assert.cursor_at(1, 1)
    end)
  end)

  describe("backward", function()
    it("pre from a pattern", function()
      h.get_preset("<a> <a>", { 1, 6 })()
      api_helpers.hop("backward", "pre", pattern)
      assert.cursor_at(1, 3)
    end)

    it("pre from pre a pattern", function()
      h.get_preset("<a> <a>|", { 1, 7 })()
      api_helpers.hop("backward", "pre", pattern)
      assert.cursor_at(1, 3)
    end)

    it("end from a pattern", function()
      h.get_preset("<a> <a>", { 1, 6 })()
      api_helpers.hop("backward", "end", pattern)
      assert.cursor_at(1, 2)
    end)

    it("start from a pattern", function()
      h.get_preset("aaa", { 1, 2 })()
      api_helpers.hop("backward", "start", "a")
      assert.cursor_at(1, 1)
    end)

    it("post from a pattern", function()
      h.get_preset("aaa", { 1, 2 })()
      api_helpers.hop("backward", "post", "a")
      assert.cursor_at(1, 1)
    end)
  end)

  describe("insert-mode", function()
    it('insert_mode_target_side = "left"', function()
      h.get_preset("aaaa", { 1, 0 })()
      h.trigger_insert()
      api_helpers.hop("forward", "start", "a", {
        insert_mode_target_side = "left",
        count = 2,
      })
      assert.cursor_at(1, 1)
    end)

    it('insert_mode_target_side = "right"', function()
      h.get_preset("aaaa", { 1, 0 })()
      h.trigger_insert()
      api_helpers.hop("forward", "start", "a", {
        insert_mode_target_side = "right",
        count = 2,
      })
      assert.cursor_at(1, 1)
    end)
  end)
end)
