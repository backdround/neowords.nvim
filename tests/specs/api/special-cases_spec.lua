local h = require("tests.helpers")
local hop = require("tests.api-helpers").hop

require("tests.custom-asserts").register()

describe("special-cases", function()
  before_each(h.get_preset([[
    aa aaBC bb bb
    aa aa
  ]], { 1, 7 }))

  describe("\\n cases", function()
    describe("normal mode", function()
      it("without offset", function()
        hop("\\v$", "forward", "start")
        assert.cursor_at(1, 13)
      end)

      it("with offset", function()
        hop("\\v$", "forward", "start", { offset = 1 })
        assert.cursor_at(2, 1)
      end)
    end)

    it("visual mode", function()
      h.trigger_visual()
      hop("\\v$", "forward", "start")
      assert.selected_region({ 1, 7 }, { 1, 14 })
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
      assert.cursor_at(1, 13)
    end)
  end)

  it("multi-byte text", function()
    h.get_preset("некоторый текст", { 1, 1 })()
    hop("\\v[[:lower:]]+", "forward", "end")
    assert.cursor_at(1, 9)
  end)

  it("multi-column text", function()
    local double_tab = "		"
    local buffer = "text" .. double_tab .. "here"
    h.get_preset(buffer, { 1, 1 })()
    hop("\\v[[:lower:]]+", "forward", "start")
    assert.cursor_at(1, 7)
  end)

  describe("should work properly with 'selection' == 'exclusive'", function()
    before_each(function()
      vim.go.selection = "exclusive"
    end)

    it("during backward hop", function()
      h.trigger_visual()
      hop("\\Maa", "backward", "start")
      assert.selected_region({ 1, 4 }, { 1, 7 })
    end)

    it("during forward hop", function()
      h.trigger_visual()
      hop("\\Mbb", "forward", "start", {
        offset = -1,
      })
      assert.selected_region({ 1, 7 }, { 1, 9 })
    end)

    it("current symbol", function()
      h.trigger_visual()
      hop("\\MC", "forward", "start")
      assert.selected_region({ 1, 7 }, { 1, 8 })
    end)

    it("previous symbol", function()
      h.trigger_visual()
      hop("\\MB", "backward", "start")
      assert.selected_region({ 1, 6 }, { 1, 7 })
    end)

    it("during forward hop to a new line", function()
      h.trigger_visual()
      hop("\\Mbb", "forward", "end", {
        offset = 1,
        count = 2,
      })
      assert.selected_region({ 1, 7 }, { 2, 1 })
    end)
  end)
end)
