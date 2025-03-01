-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local wibox = require("wibox")
local gtable = require("gears.table")
local bt = require("beautiful")

local mouse = require("util.mouse")


local button = { mt = {} }

local function on_enter(self)
    self:set_fg(self.focus_color)
    self:emit_signal("widget::redraw_needed")
    mouse.set_cursor("hand2")
end

local function on_leave(self)
    self:set_fg(self.normal_color)
    self:emit_signal("widget::redraw_needed")
    mouse.set_cursor("left_ptr")
end

function button.on_remove(self)
    if not self._popup then return end

    local instance = self._popup.instance
    if instance and instance._private.screen == self._private.screen then
        instance:detach()
        instance:emit_signal("popup::hide")
    end
end

function button.new(args)
    local ret = wibox.container.background {
        widget = args.widget
    }
    ret._private = ret._private or {}
    ret._popup = args.popup
    ret._private.screen = args.screen
    ret._private.attach = args.attach
    gtable.crush(ret, button, true)

    ret.normal_color = args.normal_color or bt.fg_normal
    ret.focus_color = args.focus_color or bt.border_focus
    ret:set_fg(ret.normal_color)

    ret:connect_signal("mouse::enter", on_enter)
    ret:connect_signal("mouse::leave", on_leave)
    ret:connect_signal("bar::removed", button.on_remove)
    return ret
end

function button.mt:__call(...)
    return button.new(...)
end

return setmetatable(button, button.mt)
