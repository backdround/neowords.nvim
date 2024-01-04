local h = require("tests.helpers")
local hop = require("tests.api-helpers").hop

require("tests.custom-asserts").register()

describe("basic", function()
  before_each(h.get_preset([[
    aa aa | bb bb
    aa aa
  ]], { 1, 6 }))

  it("no match", function()
    local performed = hop("aaa", "forward", "start")
    assert.is.False(performed)
    assert.cursor_at(1, 6)
  end)

  it("there is a match", function()
    local performed = hop("bb", "forward", "start")
    assert.is.True(performed)
    assert.cursor_at(1, 8)
  end)

  describe("normal mode", function()
    it("forward", function()
      hop("aa", "forward", "start")
      assert.cursor_at(2, 0)
    end)

    it("backward", function()
      hop("aa", "backward", "start")
      assert.cursor_at(1, 3)
    end)
  end)

  describe("insert mode", function()
    it("forward", function()
      h.trigger_insert()
      hop("aa", "forward", "start", { count = 2 })
      h.reset_mode()
      assert.cursor_at(2, 2)
    end)

    it("backward", function()
      h.trigger_insert()
      hop("aa", "backward", "start")
      h.reset_mode()
      assert.cursor_at(1, 2)
    end)
  end)

  describe("visual mode", function()
    it("forward", function()
      h.trigger_visual()
      hop("aa", "forward", "start")
      assert.selected_region({ 1, 6 }, { 2, 0 })
    end)

    it("backward", function()
      h.trigger_visual()
      hop("aa", "backward", "start")
      assert.selected_region({ 1, 3 }, { 1, 6 })
    end)
  end)

  describe("operator-pending mode", function()
    it("forward", function()
      h.trigger_delete()
      hop("aa", "forward", "end")
      assert.buffer("aa aa  aa")
    end)

    it("backward", function()
      h.trigger_delete()
      hop("aa", "backward", "start")
      assert.buffer([[
        aa | bb bb
        aa aa
      ]])
    end)
  end)
end)
