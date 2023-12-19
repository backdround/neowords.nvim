# Neowords.nvim

It's a Neovim plugin that provides flexible and reliable hops by any type
of words. It reimplements basic `w`, `e`, `b`, `ge` movements but
allows a user to have a fine tune over them.

It:
- treats `corner cases` well (`cw` and others).
- works with `non-ascii` text;
- works also in `insert` mode;

## Show cases
### Sub words only
```lua
-- Ignore anything except sub words!
local CamelCase = "sneak_UPPER_MIXEDCase" .. "1234"
--    ^    ^       ^     ^     ^    ^         ^
```
<details><summary>Configuration</summary>

```lua
local neowords = require("neowords")
local p = neowords.pattern_presets

local subword_hops = neowords.get_word_hops(
  p.sneak_case,
  p.camel_case,
  p.upper_case,
  p.number,
  p.hex_color
)

vim.keymap.set({ "n", "x", "o" }, "w", subword_hops.forward_start)
vim.keymap.set({ "n", "x", "o" }, "e", subword_hops.forward_end)
vim.keymap.set({ "n", "x", "o" }, "b", subword_hops.backward_start)
vim.keymap.set({ "n", "x", "o" }, "ge", subword_hops.backward_end)
```

</details>

<br>

### Big words only
```lua
-- Ignore anything except big words!
local CamelCase = "sneak_UPPER_MIXEDCase" .. "1234" .. "dashed-case"
--    ^            ^                          ^         ^
```
<details><summary>Configuration</summary>

```lua
local neowords = require("neowords")
local p = neowords.pattern_presets

local bigword_hops = neowords.get_word_hops(
  p.any_word,
  p.number,
  p.hex_color
)

vim.keymap.set({ "n", "x", "o" }, "w", bigword_hops.forward_start)
vim.keymap.set({ "n", "x", "o" }, "e", bigword_hops.forward_end)
vim.keymap.set({ "n", "x", "o" }, "b", bigword_hops.backward_start)
vim.keymap.set({ "n", "x", "o" }, "ge", bigword_hops.backward_end)
```

</details>

<br>

### Sub words with dots and commas
```lua
-- Jump over subwords, dots and commas!
error("Unable to " .. description .. ": " .. error_message, 2)
--     ^      ^    ^  ^           ^       ^  ^     ^      ^ ^
```
<details><summary>Configuration</summary>

```lua
local neowords = require("neowords")
local p = neowords.pattern_presets

local hops = neowords.get_word_hops(
  p.sneak_case,
  p.camel_case,
  p.upper_case,
  p.number,
  p.hex_color,
  "\\v\\.+",
  "\\v,+"
)

vim.keymap.set({ "n", "x", "o" }, "w", hops.forward_start)
vim.keymap.set({ "n", "x", "o" }, "e", hops.forward_end)
vim.keymap.set({ "n", "x", "o" }, "b", hops.backward_start)
vim.keymap.set({ "n", "x", "o" }, "ge", hops.backward_end)
```

</details>

<br>

### Numbers and hex color words
```lua
-- Ignore anything except number and color words!
local CamelCase = "99 sneak_UPPER_MIXEDCase" .. "1234" .. "dashed-case"
--                 ^                             ^
local my_cool_color = "#E3B8EF"
--                     ^
```
<details><summary>Configuration</summary>

```lua
local neowords = require("neowords")
local p = neowords.pattern_presets

local hops = neowords.get_word_hops(
  p.number,
  p.hex_color
)

vim.keymap.set({ "n", "x", "o" }, "w", hops.forward_start)
vim.keymap.set({ "n", "x", "o" }, "e", hops.forward_end)
vim.keymap.set({ "n", "x", "o" }, "b", hops.backward_start)
vim.keymap.set({ "n", "x", "o" }, "ge", hops.backward_end)
```

</details>

<br>

## Configure as you wish

```lua
local neowords = require("neowords")
local presets = neowords.pattern_presets

local hops = neowords.get_word_hops(
  -- Any vim patterns separated by comma here.
  -- Check examples above
)

vim.keymap.set({ "n", "x", "o" }, "w", hops.forward_start)
vim.keymap.set({ "n", "x", "o" }, "e", hops.forward_end)
vim.keymap.set({ "n", "x", "o" }, "b", hops.backward_start)
vim.keymap.set({ "n", "x", "o" }, "ge", hops.backward_end)
```

If you can't configure your case, make an issue!