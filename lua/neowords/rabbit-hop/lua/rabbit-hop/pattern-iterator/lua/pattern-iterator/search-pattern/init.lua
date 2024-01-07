---@class PI_Match
---@field start_position PI_Position
---@field end_position PI_Position

local current = require(({ ... })[1] .. ".current") -- require("./current")
local previous = require(({ ... })[1] .. ".previous") -- require("./previous")
local next = require(({ ... })[1] .. ".next") -- require("./next")

local M = {
  current = current,
  previous = previous,
  next = next,
}

return M
