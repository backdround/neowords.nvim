local h = require("tests.helpers")
local position = require("pattern-iterator.position")

require("tests.custom-asserts").register()

describe("position", function()
  before_each(h.get_preset([[
    some
    words
    here
  ]]))

  describe("create", function()
    describe("from the cursor", function()
      it("in bounds", function()
        h.set_cursor(2, 2)
        local p = position.from_cursor(true)
        assert.position(p, { 2, 2, true })
      end)

      it("on the end of a line with n_is_pointable == false", function()
        h.trigger_visual()

        h.set_cursor(2, 6)
        local p = position.from_cursor(false)

        assert.position(p, { 2, 5, false })
      end)

      it("on the end of a line with n_is_pointable == true", function()
        h.trigger_visual()

        h.set_cursor(2, 6)
        local p = position.from_cursor(true)

        assert.position(p, { 2, 6, true })
      end)
    end)

    describe("from given coordinates", function()
      it("in bounds", function()
        local p = position.from_coordinates(2, 4, true)
        assert.position(p, { 2, 4, true })
      end)

      it("on the end of a line with n_is_pointable == false", function()
        local p = position.from_coordinates(2, 6, false)
        assert.position(p, { 2, 5, false })
      end)

      it("on the end of a line with n_is_pointable == true", function()
        local p = position.from_coordinates(2, 6, true)
        assert.position(p, { 2, 6, true })
      end)

      it("out of bounds", function()
        local p = position.from_coordinates(-1, 6, true)
        assert.position(p, { 1, 1, true })

        p = position.from_coordinates(4, 6, true)
        assert.position(p, { 3, 5, true })

        p = position.from_coordinates(2, -1, true)
        assert.position(p, { 2, 1, true })

        p = position.from_coordinates(2, 21, true)
        assert.position(p, { 2, 6, true })
      end)
    end)

    it("by copy", function()
      local p1 = position.from_coordinates(2, 4, true)
      local p2 = vim.deepcopy(p1)
      p1:move(1)

      assert.position(p2, { 2, 4, true })
    end)
  end)

  describe("move", function()
    it("forward", function()
      local p = position.from_coordinates(2, 4, true)
      p:move(1)

      assert.position(p, { 2, 5, true })
    end)

    it("backward", function()
      local p = position.from_coordinates(2, 4, true)
      p:move(-1)

      assert.position(p, { 2, 3, true })
    end)

    it("on next line", function()
      local p = position.from_coordinates(2, 5, true)
      p:move(2)

      assert.position(p, { 3, 1, true })
    end)

    it("on previous line", function()
      local p = position.from_coordinates(2, 3, true)
      p:move(-4)

      assert.position(p, { 1, 4, true })
    end)

    it("through an empty line forward", function()
      h.get_preset([[
        some

        here
      ]])()

      local p = position.from_coordinates(1, 3, false)
      p:move(4)

      assert.position(p, { 3, 2, false })
    end)

    it("through an empty line backward", function()
      h.get_preset([[
        some

        here
      ]])()

      local p = position.from_coordinates(3, 2, false)
      p:move(-4)

      assert.position(p, { 1, 3, false })
    end)

    it("stuck against the end of the buffer", function()
      local p = position.from_coordinates(3, 1, false)
      p:move(4)

      assert.position(p, { 3, 4, false })
    end)

    it("stuck against the start of the buffer", function()
      local p = position.from_coordinates(1, 4, false)
      p:move(-4)

      assert.position(p, { 1, 1, false })
    end)
  end)

  describe("compare", function()
    it("less", function()
      local p1 = position.from_coordinates(2, 4, false)
      local p2 = position.from_coordinates(2, 5, false)
      assert.is.True(p1 < p2)
    end)

    it("not less", function()
      local p1 = position.from_coordinates(2, 5, false)
      local p2 = position.from_coordinates(2, 4, false)
      assert.is.Not.True(p1 < p2)
    end)

    it("equal", function()
      local p1 = position.from_coordinates(2, 4, false)
      local p2 = position.from_coordinates(2, 4, false)
      assert.is.True(p1 == p2)
    end)

    it("not equal", function()
      local p1 = position.from_coordinates(2, 4, false)
      local p2 = position.from_coordinates(2, 5, false)
      assert.is.Not.True(p1 == p2)
    end)
  end)

  describe("act", function()
    it("set_n_is_pointable", function()
      local p = position.from_coordinates(2, 6, true)
      assert.position(p, { 2, 6, true })

      p:set_n_is_pointable(false)
      assert.position(p, { 2, 5, false })

      p:move(1)
      assert.position(p, { 3, 1, false })

      p:set_n_is_pointable(true)
      p:move(-1)
      assert.position(p, { 2, 6, true })
    end)

    it("on_cursor", function()
      local p = position.from_coordinates(2, 3, true)
      h.set_cursor(2, 2)
      assert.is.False(p:on_cursor())

      h.set_cursor(2, 3)
      assert.is.True(p:on_cursor())

      h.set_cursor(2, 4)
      assert.is.False(p:on_cursor())
    end)

    it("after_cursor", function()
      local p = position.from_coordinates(2, 3, true)
      h.set_cursor(2, 2)
      assert.is.True(p:after_cursor())

      h.set_cursor(2, 3)
      assert.is.False(p:after_cursor())

      h.set_cursor(2, 4)
      assert.is.False(p:after_cursor())
    end)

    it("before_cursor", function()
      local p = position.from_coordinates(2, 3, true)
      h.set_cursor(2, 4)
      assert.is.True(p:before_cursor())

      h.set_cursor(2, 3)
      assert.is.False(p:before_cursor())

      h.set_cursor(2, 2)
      assert.is.False(p:before_cursor())
    end)

    describe("select_region_to", function()
      it("forward", function()
        local p1 = position.from_coordinates(1, 4, false)
        local p2 = position.from_coordinates(2, 5, false)
        p1:select_region_to(p2)
        assert.selected_region({ 1, 4 }, { 2, 5 })
      end)

      it("backward", function()
        local p1 = position.from_coordinates(1, 4, false)
        local p2 = position.from_coordinates(2, 5, false)
        p2:select_region_to(p1)
        assert.selected_region({ 1, 4 }, { 2, 5 })
      end)

      it("in visual mode", function()
        h.trigger_visual()

        local p1 = position.from_coordinates(1, 4, false)
        local p2 = position.from_coordinates(2, 3, false)
        p1:select_region_to(p2)

        assert.selected_region({ 1, 4 }, { 2, 3 })
      end)

      it("with 'selection' == 'exclusive'", function()
        vim.go.selection = "exclusive"

        local p1 = position.from_coordinates(1, 4, false)
        local p2 = position.from_coordinates(2, 3, false)
        p1:select_region_to(p2)

        h.feedkeys("d", true)

        assert.buffer([[
          somds
          here
        ]])
      end)

      describe("in operator-pending mode", function()
        it("forward", function()
          local p1 = position.from_coordinates(1, 4, true)
          local p2 = position.from_coordinates(2, 6, true)
          h.trigger_delete()
          h.perform_through_keymap(p1.select_region_to, true, p1, p2)
          assert.buffer("somhere")
        end)

        it("backward", function()
          local p1 = position.from_coordinates(1, 4, true)
          local p2 = position.from_coordinates(2, 6, true)
          h.trigger_delete()
          h.perform_through_keymap(p2.select_region_to, true, p2, p1)
          assert.buffer("somhere")
        end)

        it("in dot repeat", function()
          local captured_data = {
            p1 = position.from_coordinates(1, 1, true),
            p2 = position.from_coordinates(1, 4, true),
          }

          h.feedkeys("c", false)
          h.perform_through_keymap(function()
            captured_data.p1:select_region_to(captured_data.p2)
          end, false)
          h.feedkeys("aa", false)
          h.feedkeys("<esc>", true)

          assert.buffer([[
            aa
            words
            here
          ]])

          captured_data.p1 = position.from_coordinates(2, 1, true)
          captured_data.p2 = position.from_coordinates(2, 5, true)
          h.feedkeys(".", true)

          assert.buffer([[
            aa
            aa
            here
          ]])
        end)

        describe("with 'selection' == 'exclusive'", function()
          it("forward", function()
            vim.go.selection = "exclusive"

            h.feedkeys("d", false)
            h.perform_through_keymap(function()
              local p1 = position.from_coordinates(1, 4, false)
              local p2 = position.from_coordinates(2, 3, false)
              p1:select_region_to(p2)
            end, true)

            assert.buffer([[
              somds
              here
            ]])
          end)

          it("backward", function()
            vim.go.selection = "exclusive"

            h.feedkeys("d", false)
            h.perform_through_keymap(function()
              local p1 = position.from_coordinates(1, 4, false)
              local p2 = position.from_coordinates(2, 3, false)
              p2:select_region_to(p1)
            end, true)

            assert.buffer([[
              somds
              here
            ]])
          end)
        end)
      end)

      describe("should work after", function()
        local select_region = function(coords1, coords2)
          local p1 = position.from_coordinates(coords1[1], coords1[2], false)
          local p2 = position.from_coordinates(coords2[1], coords2[2], false)
          p1:select_region_to(p2)
        end

        it("none visual selection", function()
          select_region({ 1, 4 }, { 2, 3 })
          assert.selected_region({ 1, 4 }, { 2, 3 })
          assert.are.same("v", vim.fn.visualmode())
        end)

        it("linewise visual selection", function()
          h.feedkeys("V<esc>", true)

          select_region({ 1, 4 }, { 2, 3 })
          assert.selected_region({ 1, 4 }, { 2, 3 })
          assert.are.same("v", vim.fn.visualmode())
        end)

        it("charwise visual selection", function()
          h.feedkeys("v<esc>", true)

          select_region({ 1, 4 }, { 2, 3 })
          assert.selected_region({ 1, 4 }, { 2, 3 })
          assert.are.same("v", vim.fn.visualmode())
        end)

        it("blockwise visual selection", function()
          h.feedkeys("<C-v><esc>", true)

          select_region({ 1, 4 }, { 2, 3 })
          assert.selected_region({ 1, 4 }, { 2, 3 })
          assert.are.same("v", vim.fn.visualmode())
        end)
      end)
    end)

    describe("set_cursor", function()
      it("in normal mode", function()
        h.set_cursor(1, 1)
        local p = position.from_coordinates(2, 4, false)
        p:set_cursor()
        assert.cursor_at(2, 4)
      end)

      it("in normal mode to the end of a line", function()
        h.set_cursor(1, 1)
        local p = position.from_coordinates(2, 6, true)
        p:set_cursor()
        assert.cursor_at(2, 5)
      end)

      it("in visual mode", function()
        h.set_cursor(1, 3)

        h.trigger_visual()
        local p = position.from_coordinates(2, 4, true)
        p:set_cursor()

        assert.selected_region({ 1, 3 }, { 2, 4 })
      end)

      it("in visual mode to the end of a line", function()
        h.set_cursor(1, 3)

        h.trigger_visual()
        local p = position.from_coordinates(2, 6, true)
        p:set_cursor()

        assert.selected_region({ 1, 3 }, { 2, 6 })
      end)

      it("in operator-pending mode", function()
        h.trigger_delete()

        h.perform_through_keymap(function()
          local p = position.from_coordinates(3, 1, true)
          p:set_cursor()
        end, true)

        assert.buffer("here")
      end)

      it("in insert mode", function()
        h.trigger_insert()

        h.perform_through_keymap(function()
          local p = position.from_coordinates(3, 2, true)
          p:set_cursor()
        end, true)

        assert.cursor_at(3, 1)
      end)
    end)
  end)

  describe("with multi-byte characters", function()
    before_each(h.get_preset([[
      тут
      несколько
      слов
    ]], { 1, 3 }))

    describe("create", function()
      it("from cursor", function()
        local p = position.from_cursor(true)
        assert.position(p, { 1, 3, true })
      end)

      it("from coordinates", function()
        local p = position.from_coordinates(2, 4, true)
        assert.position(p, { 2, 4, true })
      end)
    end)

    describe("move", function()
      it("forward", function()
        local p = position.from_coordinates(1, 3, true)
        p:move(2)
        assert.position(p, { 2, 1, true })
      end)

      it("backward", function()
        local p = position.from_coordinates(2, 3, true)
        p:move(-4)
        assert.position(p, { 1, 3, true })
      end)
    end)

    describe("act", function()
      it("after_cursor", function()
        local p = position.from_coordinates(1, 4, true)
        assert.is.True(p:after_cursor())
        p:move(-1)
        assert.is.False(p:after_cursor())
      end)

      it("before_cursor", function()
        local p = position.from_coordinates(1, 2, true)
        assert.is.True(p:before_cursor())
        p:move(1)
        assert.is.False(p:before_cursor())
      end)

      it("select_region_to", function()
        local p1 = position.from_coordinates(2, 2, true)
        local p2 = position.from_coordinates(3, 2, true)

        p1:select_region_to(p2)
        h.feedkeys("d", true)

        assert.buffer([[
          тут
          нов
        ]])
      end)

      it("set_cursor", function()
        local p1 = position.from_cursor(true)
        p1:move(3)
        p1:set_cursor()

        p1 = position.from_cursor(true)
        local p2 = position.from_coordinates(3, 2, true)

        p1:select_region_to(p2)
        h.feedkeys("d", true)

        assert.buffer([[
          тут
          нов
        ]])
      end)
    end)
  end)

  describe("with multi-column characters", function()
    local double_tab = "		"
    local buffer = ([[
      |%ssome
      |%stabs
      |%shere
    ]]):format(double_tab, double_tab, double_tab)
    before_each(h.get_preset(buffer, { 2, 4 }))

    describe("create", function()
      it("from cursor", function()
        local p = position.from_cursor(true)
        assert.position(p, { 2, 4, true })
      end)

      it("from coordinates", function()
        local p = position.from_coordinates(1, 4, true)
        assert.position(p, { 1, 4, true })
      end)
    end)

    describe("move", function()
      it("forward", function()
        local p = position.from_coordinates(1, 1, true)
        p:move(8)
        assert.position(p, { 2, 1, true })
      end)

      it("backward", function()
        local p = position.from_coordinates(2, 3, true)
        p:move(-3)
        assert.position(p, { 1, 8, true })
      end)
    end)

    describe("act", function()
      it("after_cursor", function()
        local p = position.from_coordinates(2, 5, true)
        assert.is.True(p:after_cursor())
        p:move(-1)
        assert.is.False(p:after_cursor())
      end)

      it("before_cursor", function()
        local p = position.from_coordinates(2, 3, true)
        assert.is.True(p:before_cursor())
        p:move(1)
        assert.is.False(p:before_cursor())
      end)

      it("select_region_to", function()
        local p1 = position.from_coordinates(2, 2, true)
        local p2 = position.from_coordinates(3, 2, true)

        p1:select_region_to(p2)
        h.feedkeys("d", true)

        assert.buffer([[
          |		some
          |	here
        ]])
      end)

      it("set_cursor", function()
        local p1 = position.from_coordinates(1, 4, true)
        p1:set_cursor()
        p1 = position.from_cursor(true)

        local p2 = position.from_coordinates(3, 3, true)

        p1:select_region_to(p2)
        h.feedkeys("d", true)

        assert.buffer([[
          |		here
        ]])
      end)
    end)
  end)
end)
