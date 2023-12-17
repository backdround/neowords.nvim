local api_helpers = require("tests.api-helpers")
local h = require("tests.helpers")

require("tests.custom-asserts").register()

describe("v:count", function()
  before_each(h.get_preset([[
    <a> <a> <a> <a> <a>
  ]], { 1, 0 }))
  local pattern = "\\M<a>"

  it("should be respected during hop", function()
    api_helpers.hop("forward", "start", pattern, {
      count = 3,
    })
    assert.cursor_at(1, 12)
  end)

  it(
    "should be taken as a maximal possible count if v:count is too big",
    function()
      api_helpers.hop("forward", "start", pattern, {
        count = 22,
      })
      assert.cursor_at(1, 16)
    end
  )
end)
