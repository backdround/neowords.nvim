local M = {
  snake_case = "\\v"
    -- Ignore camelcase words.
    .. "[[:upper:][:lower:]]@<!"
    -- Match lowercase words.
    .. "[[:lower:]]+"
    -- Ignore if the match is a hex color (or a part of it).
    .. "(#[[:xdigit:]]+)@<!",

  camel_case = "\\v"
    -- Match camelcase words.
    .. "[[:upper:]][[:lower:]]+",

  upper_case = "\\v"
    -- Match uppercase words.
    .. "[[:upper:]]+"
    -- Ignore if the match is a hex color (or a part of it).
    .. "(#[[:xdigit:]]+)@<!"
    -- Ignore camelcase words.
    .. "[[:lower:]]@!",

  number = "\\v"
    -- Match numbers.
    .. "[-+]?[[:digit:]]+"
    -- Ignore if the match is a hex color (or a part of it).
    .. "(#[[:xdigit:]]+)@<!",

  hex_color = "\\v"
    -- Match a hex color, the largest is in priority.
    .. "#([[:xdigit:]]{8}|[[:xdigit:]]{6}|[[:xdigit:]]{4}|[[:xdigit:]]{3})"
    -- Ignore if there is anything after the match like "ine" in "#define".
    .. "[[:lower:][:upper:][:digit:]]@!",

  any_word = "\\v"
    -- Don't start the match with "-"
    .. "-@!"
    -- Match any words with optional numbers.
    .. "[-_[:lower:][:upper:][:digit:]]+",
}

return M
