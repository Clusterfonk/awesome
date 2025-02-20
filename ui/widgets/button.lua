-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local wibox = require("wibox")
local gtable = require("gears.table")
local bt = require("beautiful")

local mouse = require("utilities.mouse")


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

local function on_press(self, lx, ly, btn, mode, mods)
    if btn == 1 then
        self:emit_signal("button::lmb_press")
    elseif btn == 3 then
        self:emit_signal("button::rmb_press")
    elseif btn == 4 then
        self:emit_signal("button::mousescrollup")
    elseif btn == 5 then
        self:emit_signal("button::mousescrolldown")
    end
end

function button.new(args)
    local widget = wibox.container.background {
        widget = args.widget,
    }

    widget.normal_color = args.normal_color or bt.fg_normal
    widget.focus_color = args.focus_color or bt.border_focus
    widget:set_fg(widget.normal_color)

    gtable.crush(widget, button, true)

    widget:connect_signal("mouse::enter", on_enter)
    widget:connect_signal("mouse::leave", on_leave)
    widget:connect_signal("button::press", on_press)

    return widget
end

function button.mt:__call(...)
    return button.new(...)
end

return setmetatable(button, button.mt)
