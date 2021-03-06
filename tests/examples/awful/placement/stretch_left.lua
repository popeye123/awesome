-- Stretch the drawable to the left of the parent area. --DOC_HEADER
-- @tparam drawable d A drawable (like `client` or `wibox`) --DOC_HEADER
-- @tparam[opt={}] table args Other arguments --DOC_HEADER
-- @name stretch_left --DOC_HEADER
-- @class function --DOC_HEADER

screen[1]._resize {width = 128, height = 96} --DOC_HIDE
local placement = require("awful.placement") --DOC_HIDE

local c = client.gen_fake {x = 45, y = 35, width=40, height=30} --DOC_HIDE
placement.stretch_left(client.focus)

assert(c.x == 0 and c.y == 35 and c.height == 30) --DOC_HIDE
print(c.width-2*c.border_width  == 45+40) --DOC_HIDE
