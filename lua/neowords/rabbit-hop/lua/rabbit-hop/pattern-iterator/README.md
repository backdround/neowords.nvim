# Pattern-iterator.nvim

<p align="center">
  <a href="https://github.com/backdround/pattern-iterator.nvim/actions">
    <img src="https://img.shields.io/github/actions/workflow/status/backdround/pattern-iterator.nvim/tests.yaml?branch=main&label=Tests&style=flat-square" alt="Tests">
  </a>
  <a href="https://github.com/backdround/pattern-iterator.nvim/actions">
    <img src="https://img.shields.io/github/actions/workflow/status/backdround/pattern-iterator.nvim/docs.yaml?branch=main&label=Doc%20generation&status=gen&style=flat-square" alt="Tests">
  </a>
</p>

It's a Neovim plugin that provides an iterator over vim-pattern matches
in the buffer text. It can be use as API for another plugin.

## Visual representation
```lua
local target_position = search_target_posi┃tion(opts, n_is_pointable)
--           ^------^                 ^-------^                      
--          previous()      <=     new_around("position")     =>     
if not target_position then
--            ^------^     
--      =>     next()      
```

## Usage example
```lua
local pattern_iterator = require("pattern-iterator")

local function place_cursor_to_end_of_lower_word()
  local lower_word_pattern = "\\v[[:lower:]]+"

  local iterator = pattern_iterator.new_around(lower_word_pattern, {})
    or pattern_iterator.new_forward(lower_word_pattern, {})

  if iterator == nil then
    return
  end

  iterator:end_position():set_cursor()
end
```

## Usage in your plugin

Add the plugin as a subtree in your git repository:
```bash
git subtree add --squash \
    --prefix=pattern-iterator.nvim \
    git@github.com:backdround/pattern-iterator.nvim.git main
```

Create a symlink from `./lua/your-plugin-name` directory:
```bash
ln -s ../../pattern-iterator.nvim/lua/pattern-iterator pattern-iterator
```

Use the API from your code:
```lua
local pattern_iterator = require("your-plugin-name.pattern-iterator")
```

## API

### Module
Function | Return type | Description
-- | -- | --
new_around(pattern,options?) | PI_Iterator? | Creates an iterator that points to a current match at the given position or the cursor. Returns nil if there is no pattern at the position.
new_forward(pattern,options?) | PI_Iterator? | Creates an iterator that points to a match after the given position or the cursor. Returns nil if there is no pattern after the position.
new_backward(pattern,options?) | PI_Iterator? | Creates an iterator that points to a match before the given position or the cursor. Returns nil if there is no pattern before the position.

```lua
local options = {
  -- base position to search from.
  -- It's 1-based line and 1-based character index.
  -- If nil then it uses the cursor position.
  from_search_position = { 2, 6 },
  -- Used to indicate if the end of the line `\n` is pointable.
  -- If nil then it calculates based on the current mode (mode ~= "normal").
  n_is_pointable = true,
}
```

### PI_Iterator
Method | Return type | Description
-- | -- | --
next(count?) | boolean | Advances the iterator forward to the count of matches. Returned boolean indicates that the iterator hasn't stuck on the last match yet.
previous(count?) | boolean | Advances the iterator backward to the count of matches. Returned boolean indicates that the iterator hasn't stuck on the first match yet.
start_position() | PI_Position | The start position of the current match.
end_position() | PI_Position | The end position of the current match.

### PI_Position

Method / Member | Return type | Description
-- | -- | --
set_cursor() | - | Sets the cursor to the position.
select_region_to(position) | - | Selects a region between the current and another position.
on_cursor() | boolean | Indicates that the current position is on the cursor.
before_cursor() | boolean | Indicates that the current position is before the cursor.
after_cursor() | boolean | Indicates that the current position is after the cursor.
move(offset) | - | Moves the position according to the offset. If offset > 0 then it moves forward else backward.
set_n_is_pointable(n_is_pointable) | - | Sets the flag that indicates that the position can point to the `\n`.
line | number | 1-based position's line.
char_index | number | 1-based position's char index.
n_is_pointable | boolean | The flag that indicates that the position can point to the `\n`.
