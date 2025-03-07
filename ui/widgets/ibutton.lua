-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local awful = require("awful")
local wibox = require("wibox")
local gtable = require("gears.table")
local bt = require("beautiful")
local dpi = bt.xresources.apply_dpi

local umouse = require("util.mouse")


local ibutton = { mt = {} }

ibutton.icons = {
    normal = nil,
    normal_focus = nil,
    active = nil,
    active_focus = nil,
}

local function on_enter(self)
    if not self._private.hovered then
        self._private.hovered = true
        self:update_icon()
        umouse.set_cursor("hand2")
    end
end

local function on_leave(self)
    if self._private.hovered then
        self._private.hovered = false
        self:update_icon()
        umouse.set_cursor("left_ptr")
    end
end

-- State-to-icon mapping
function ibutton:get_icon()
    local i = self._private.icons
    if self._private.active then
        return self._private.hovered and i.active_focus or i.active
    else
        return self._private.hovered and i.normal_focus or i.normal
    end
end

function ibutton:update_icon()
    local icon = self:get_icon()
    self._private.imagebox:set_image(icon)
    self:emit_signal("widget::redraw_needed")
end

function ibutton.new(args)
    args = args or {}
    assert(args.icons, "Icons must be provided to ibutton")

    local imagebox = wibox.widget {
        id = "imagebox",
        widget = wibox.widget.imagebox,
        image = args.icons.normal,             -- TODO: ONLY TEMP.
        forced_height = args.height - 2 * dpi(2),
        forced_width = args.height - 2 * dpi(2)
    }

    local ret = wibox.widget {
        widget = wibox.container.margin,
        margins = args.margins,
        {
            widget = wibox.container.place,
            valign = "center",
            halign = "center",
            imagebox
        },
    }
    ret._private = ret._private or {}
    ret._private.hovered = false
    ret._private.active = false
    ret._private.icons = args.icons
    ret._private.imagebox = imagebox
    ret._private.screen = args.screen
    ret._private.attach = args.attach
    ret._popup = args.popup
    gtable.crush(ret, ibutton, true)

    ret:connect_signal("mouse::enter", on_enter)
    ret:connect_signal("mouse::leave", on_leave)
    return ret
end

function ibutton.mt:__call(...)
    return ibutton.new(...)
end

return setmetatable(ibutton, ibutton.mt)
