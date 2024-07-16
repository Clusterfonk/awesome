-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local wibox = require("wibox")
local gtable = require("gears.table")
local bt = require("beautiful")

local button = require("ui.widgets.button")
local popup = require("ui.popups.base")
local debug = require("utilities.debug")


clock = { mt = {} }

local function on_lmb_press(self)
    self._private.popup:emit_signal("popup::show", self._private.anchor_geo)
end

-- TODO: get screen in here
local function new(args)
    local button_widget = button {
        normal_color = args.normal_color,
        focus_color = args.focus_color,
        widget = wibox.widget {
            format = args.format,
            font = args.font,
            widget = wibox.widget.textclock
        }
    }

    local widget = wibox.widget {
        widget = wibox.container.margin,
        margins = bt.useless_gap,
        {
            widget = button_widget
        }
    }

    -- TODO: should be figured out here
    geometry = {
        x = 2
    }
    button_widget._private.popup = popup({geometry = geometry})
    button_widget:connect_signal("button::lmb_press", on_lmb_press)

    gtable.crush(widget, clock, true)
    return widget
end

function clock.mt:__call(...)
    return new(...)
end

return setmetatable(clock, clock.mt)
