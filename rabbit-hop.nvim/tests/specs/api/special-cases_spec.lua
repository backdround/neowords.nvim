local h = require("tests.helpers")
local hop = require("tests.api-helpers").hop

require("tests.custom-asserts").register()

describe("special-cases", function()
  before_each(h.get_preset([[
    aa aaBC bb bb
    aa aa
  ]], { 1, 6 }))

  describe("\\n cases", function()
    describe("normal mode", function()
      it("without offset", function()
        hop("\\v$", "forward", "start")
        assert.cursor_at(1, 12)
      end)

      it("with offset", function()
        hop("\\v$", "forward", "start", { offset = 1 })
        assert.cursor_at(2, 0)
      end)
    end)

    it("visual mode", function()
      h.trigger_visual()
      hop("\\v$", "forward", "start")
      assert.selected_region({ 1, 6 }, { 1, 13 })
    end)

    it("operator-pending mode", function()
      h.trigger_delete()
      hop("\\v$", "forward", "start")
      assert.buffer("aa aaBaa aa")
    end)

    it("insert mode", function()
      h.trigger_insert()
      hop("\\v$", "forward", "start")
      h.reset_mode()
      assert.cursor_at(1, 12)
    end)
  end)

  describe("should work properly with 'selection' == 'exclusive'", function()
    before_each(function()
      vim.go.selection = "exclusive"
    end)

    it("during backward hop", function()
      h.trigger_visual()
      hop("\\Maa", "backward", "start")
      assert.selected_region({ 1, 3 }, { 1, 6 })
    end)

    it("during forward hop", function()
      h.trigger_visual()
      hop("\\Mbb", "forward", "start", {
        offset = -1,
      })
      assert.selected_region({ 1, 6 }, { 1, 8 })
    end)

    it("current symbol", function()
      h.trigger_visual()
      hop("\\MC", "forward", "start")
      assert.selected_region({ 1, 6 }, { 1, 7 })
    end)

    it("previous symbol", function()
      h.trigger_visual()
      hop("\\MB", "backward", "start")
      assert.selected_region({ 1, 5 }, { 1, 6 })
    end)

    it("during forward hop to a new line", function()
      h.trigger_visual()
      hop("\\Mbb", "forward", "end", {
        offset = 1,
        count = 2,
      })
      assert.selected_region({ 1, 6 }, { 2, 0 })
    end)
  end)
end)
