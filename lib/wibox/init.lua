---------------------------------------------------------------------------
-- @author Uli Schlachter
-- @copyright 2010 Uli Schlachter
-- @release @AWESOME_VERSION@
-- @classmod wibox
---------------------------------------------------------------------------

local capi = {
    drawin = drawin,
    root = root,
    awesome = awesome
}
local setmetatable = setmetatable
local pairs = pairs
local type = type
local object = require("gears.object")
local beautiful = require("beautiful")
local base = require("wibox.widget.base")

--- This provides widget box windows. Every wibox can also be used as if it were
-- a drawin. All drawin functions and properties are also available on wiboxes!
-- wibox
local wibox = { mt = {} }
wibox.layout = require("wibox.layout")
wibox.widget = require("wibox.widget")
wibox.drawable = require("wibox.drawable")
wibox.hierarchy = require("wibox.hierarchy")

--- Set the widget that the wibox displays
function wibox:set_widget(widget)
    self._drawable:set_widget(widget)
end

--- Set a declarative widget hierarchy description.
-- See [The declarative layout system](../documentation/03-declarative-layout.md.html)
-- @param args An array containing the widgets disposition
-- @name setup
-- @class function
wibox.setup = base.widget.setup

--- Set the background of the wibox
-- @param c The background to use. This must either be a cairo pattern object,
--   nil or a string that gears.color() understands.
function wibox:set_bg(c)
    self._drawable:set_bg(c)
end

--- Set the background image of the drawable
-- If `image` is a function, it will be called with `(context, cr, width, height)`
-- as arguments. Any other arguments passed to this method will be appended.
-- @param image A background image or a function
function wibox:set_bgimage(image, ...)
    self._drawable:set_bgimage(image, ...)
end

--- Set the foreground of the wibox
-- @param c The foreground to use. This must either be a cairo pattern object,
--   nil or a string that gears.color() understands.
function wibox:set_fg(c)
    self._drawable:set_fg(c)
end

--- Find a widget by a point.
-- The wibox must have drawn itself at least once for this to work.
-- @param x X coordinate of the point
-- @param y Y coordinate of the point
-- @return A sorted table with all widgets that contain the given point. The
--   widgets are sorted by relevance.
function wibox:find_widgets(x, y)
    return self._drawable:find_widgets(x, y)
end

for _, k in pairs{ "buttons", "struts", "geometry", "get_xproperty", "set_xproperty" } do
    wibox[k] = function(self, ...)
        return self.drawin[k](self.drawin, ...)
    end
end

local function setup_signals(_wibox)
    local obj
    local function clone_signal(name)
        _wibox:add_signal(name)
        -- When "name" is emitted on wibox.drawin, also emit it on wibox
        obj:connect_signal(name, function(_, ...)
            _wibox:emit_signal(name, ...)
        end)
    end

    obj = _wibox.drawin
    clone_signal("property::border_color")
    clone_signal("property::border_width")
    clone_signal("property::buttons")
    clone_signal("property::cursor")
    clone_signal("property::height")
    clone_signal("property::ontop")
    clone_signal("property::opacity")
    clone_signal("property::struts")
    clone_signal("property::visible")
    clone_signal("property::width")
    clone_signal("property::x")
    clone_signal("property::y")
    clone_signal("property::geometry")
    clone_signal("property::shape_bounding")
    clone_signal("property::shape_clip")

    obj = _wibox._drawable
    clone_signal("button::press")
    clone_signal("button::release")
    clone_signal("mouse::enter")
    clone_signal("mouse::leave")
    clone_signal("mouse::move")
    clone_signal("property::surface")
end

local function new(args)
    local ret = object()
    local w = capi.drawin(args)
    ret.drawin = w
    ret._drawable = wibox.drawable(w.drawable, { wibox = ret },
        "wibox drawable (" .. object.modulename(3) .. ")")

    for k, v in pairs(wibox) do
        if type(v) == "function" then
            ret[k] = v
        end
    end

    setup_signals(ret)
    ret.draw = ret._drawable.draw
    ret.widget_at = function(_, widget, x, y, width, height)
        return ret._drawable:widget_at(widget, x, y, width, height)
    end

    -- Set the default background
    ret:set_bg(args.bg or beautiful.bg_normal)
    ret:set_fg(args.fg or beautiful.fg_normal)

    -- Add __tostring method to metatable.
    local mt = {}
    local orig_string = tostring(ret)
    mt.__tostring = function()
        return string.format("wibox: %s (%s)",
                             tostring(ret._drawable), orig_string)
    end
    ret = setmetatable(ret, mt)

    -- Make sure the wibox is drawn at least once
    ret.draw()

    -- Redirect all non-existing indexes to the "real" drawin
    setmetatable(ret, {
        __index = w,
        __newindex = w
    })

    return ret
end

--- Redraw a wibox. You should never have to call this explicitely because it is
-- automatically called when needed.
-- @param wibox
-- @function draw

--- Widget box object.
-- Every wibox "inherits" from a drawin and you can use all of drawin's
-- functions directly on this as well. When creating a wibox, you can specify a
-- "fg" and a "bg" color as keys in the table that is passed to the constructor.
-- All other arguments will be passed to drawin's constructor.
-- @table drawin

function wibox.mt:__call(...)
    return new(...)
end

return setmetatable(wibox, wibox.mt)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
