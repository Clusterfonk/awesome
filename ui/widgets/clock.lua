-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local wibox = require("wibox")
local gtable = require("gears.table")
local bt = require("beautiful")

local button = require("ui.widgets.button")


clock = { mt = {} }

function clock:focus()
    print(self)
    local span = string.format("<span foreground='%s'>", self.focus_color)
    self.markup = span .. self.text .. "</span>"
end

function clock:unfocus()
    self.markup = self.text
end

local function new(args)
    local clock_widget = wibox.widget {
        widget = wibox.widget.textclock,
        format = args.format,
        font = args.font,
        focus_color = bt.border_focus,
    }

    local widget = wibox.widget {
        widget = wibox.container.margin,
        margins = bt.useless_gap,
        {
            widget = button {
                focus_color = bt.border_focus,
                on_enter = clock.focus,
                on_leave = clock.unfocus,
            },
            clock_widget
        }
    }

    gtable.crush(widget, clock, true)
    return widget
end

function clock.mt:__call(...)
    return new(...)
end

return setmetatable(clock, clock.mt)
