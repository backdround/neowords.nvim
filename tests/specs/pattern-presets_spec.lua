local nw = require("neowords")

describe("pattern-presets", function()
  local test_text = [[
    -- showcase_string-FOR_MATCHING_ByDIFFERENTPresets554
    -- KNumber number99inside -help -999 +413 12
    -- #C3A9FA #a3a9fa #2a3a4c #IF #define #def #Stop
  ]]

  local get_matches = function(text, preset_name)
    local matches = {}

    local pattern = nw.pattern_presets[preset_name]

    local vim_matches = vim.fn.matchstrlist({ text }, pattern)
    for _, vim_match in ipairs(vim_matches) do
      table.insert(matches, vim_match.text)
    end

    return matches
  end

  it("snake_case", function()
    local expected_matches = { "showcase", "string", "number", "inside", "help", "define" }
    local real_matches = get_matches(test_text, "snake_case")

    assert.are.same(expected_matches, real_matches)
  end)

  it("camel_case", function()
    local expected_matches = { "By", "Presets", "Number", "Stop" }
    local real_matches = get_matches(test_text, "camel_case")

    assert.are.same(expected_matches, real_matches)
  end)

  it("upper_case", function()
    local expected_matches = { "FOR", "MATCHING", "DIFFERENT", "K", "IF" }
    local real_matches = get_matches(test_text, "upper_case")

    assert.are.same(expected_matches, real_matches)
  end)

  it("number", function()
    local expected_matches = { "554", "99", "-999", "+413", "12" }
    local real_matches = get_matches(test_text, "number")

    assert.are.same(expected_matches, real_matches)
  end)

  it("hex_color", function()
    local expected_matches = { "#C3A9FA", "#a3a9fa", "#2a3a4c", "#def" }
    local real_matches = get_matches(test_text, "hex_color")

    assert.are.same(expected_matches, real_matches)
  end)

  it("any_word", function()
    local expected_matches = {
      "showcase_string-FOR_MATCHING_ByDIFFERENTPresets554",
      "KNumber",
      "number99inside",
      "help",
      "999",
      "413",
      "12",
      "C3A9FA",
      "a3a9fa",
      "2a3a4c",
      "IF",
      "define",
      "def",
      "Stop",
    }
    local real_matches = get_matches(test_text, "any_word")

    assert.are.same(expected_matches, real_matches)
  end)
end)
