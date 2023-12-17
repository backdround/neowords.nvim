# Rabbit-hop.nvim

<p align="center">
  <a href="https://github.com/backdround/rabbit-hop.nvim/actions">
    <img src="https://img.shields.io/github/actions/workflow/status/backdround/rabbit-hop.nvim/tests.yaml?branch=main&label=Tests&style=flat-square" alt="Tests">
  </a>
  <a href="https://github.com/backdround/rabbit-hop.nvim/actions">
    <img src="https://img.shields.io/github/actions/workflow/status/backdround/rabbit-hop.nvim/docs.yaml?branch=main&label=Doc%20generation&status=gen&style=flat-square" alt="Tests">
  </a>
</p>

It's a Neovim plugin that provides a flexible ability to hop to a user
defined vim-pattern (quotes, brackets, numbers).

Hops work:

- in multiline;
- in `normal`, `visual`, `operator-pending` and `insert` modes;
- with non-ascii text;
- with the `count` multiplier;
- with the `dot` repetition.

The plugin:

- Can be used as api for other plugins;
- Should be stable in corner cases (has lots of tests).

<!-- panvimdoc-ignore-start -->

***

### Preview
#### Hop inside / outside round brackets
<img src="https://github.com/backdround/rabbit-hop.nvim/assets/17349169/bb300bcd-2b87-448c-bb13-483659f456af" width="600px" />

#### Hop inside / outside quotes
<img src="https://github.com/backdround/rabbit-hop.nvim/assets/17349169/d615afb0-810f-4327-9a07-fa14fdadd9c7" width="600px" />

#### Hop to a number
<img src="https://github.com/backdround/rabbit-hop.nvim/assets/17349169/60596f0c-c513-458c-80dc-734bf3d3f609" width="600px" />

***

<!-- panvimdoc-ignore-end -->

### Configuration example
```lua
local rh = require("rabbit-hop")

-- Hop forward inside round brackets.
vim.keymap.set({"n", "x", "o"}, "s", function()
  rh.hop({
    direction = "forward",
    offset = "post",
    pattern = "\\M(",
  })
end)

-- Hop backward inside round brackets.
vim.keymap.set({"n", "x", "o"}, "S", function()
  rh.hop({
    direction = "backward",
    offset = "post",
    pattern = "\\M)",
  })
end)
```

### Additional configuration examples
<details><summary>Hop to a number</summary>

```lua
-- Hop forward inside / outside round brackets.
vim.keymap.set({"n", "x", "o"}, "s", function()
  rh.hop({
    direction = "forward",
    offset = "start",
    pattern = "\\v\\d+",
  })
end)

-- Hop backward inside / outside round brackets.
vim.keymap.set({"n", "x", "o"}, "S", function()
  rh.hop({
    direction = "backward",
    offset = "start",
    pattern = "\\v\\d+",
  })
end)
```

</details>

<details><summary>Hop inside / outside quotes</summary>

```lua
-- Hop forward past quotes.
vim.keymap.set({"n", "x", "o"}, "s", function()
  rh.hop({
    direction = "forward",
    offset = "post",
    pattern = "\\v[\"'`]",
  })
end)

-- Hop backward past quotes.
vim.keymap.set({"n", "x", "o"}, "S", function()
  rh.hop({
    direction = "backward",
    offset = "post",
    pattern = "\\v[\"'`]",
  })
end)
```

</details>

<details><summary>Hop inside / outside round brackets</summary>

```lua
-- Hop forward inside / outside round brackets.
vim.keymap.set({"n", "x", "o"}, "s", function()
  rh.hop({
    direction = "forward",
    offset = "post",
    pattern = "\\v[()]",
    -- If you don't want to hop past ) which is the last character on the line,
    -- then use this pattern: "\\v((|\\)$@!)"
  })
end)

-- Hop backward inside / outside round brackets.
vim.keymap.set({"n", "x", "o"}, "S", function()
  rh.hop({
    direction = "backward",
    offset = "post",
    pattern = "\\v[()]",
  })
end)
```

</details>

<!-- panvimdoc-ignore-start -->

***

<!-- panvimdoc-ignore-end -->
### Plugin hop options

| Option | Default | Possible | Description |
| --- | --- | --- | --- |
| `direction` | `"forward"` | `"forward"`, `"backward"` | Direction to hop |
| `pattern` | - | any vim pattern | Pattern to hop |
| `offset` | `"start"` | `"pre"`, `"start"`, `"end"`, `"post"` | Cursor position relative to the pattern |
| `insert_mode_target_side` | `"left"` | `"left"`, `"right"` | Side to place the cursor in insert mode. It's applied after the offset.
