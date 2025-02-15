-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local wibox = require("wibox")
local gtable = require("gears.table")

local button = require("ui.widgets.button")
local calendar = require("ui.popups.calendar")


clock = { mt = {} }

local function on_lmb_press(self)
    self.popup:emit_signal("popup::show")
end

local function new(args)
    local button_widget = button {
        screen = args.screen,
        normal_color = args.normal_color,
        focus_color = args.focus_color,
        widget = wibox.widget {
            format = args.format,
            font = args.font,
            widget = wibox.widget.textclock
        }
    }

    button_widget.popup = calendar(args)
    button_widget:connect_signal("button::lmb_press", on_lmb_press)

    gtable.crush(button_widget, clock, true)
    return button_widget
end

function clock.mt:__call(...)
    return new(...)
end

return setmetatable(clock, clock.mt)
