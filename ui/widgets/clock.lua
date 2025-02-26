-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local wibox = require("wibox")
local gtable = require("gears.table")

local button = require("ui.widgets.button")
local calendar = require("ui.popups.calendar")


local clock = { mt = {} }

local function on_press(self, _, _, btn, _, _)
    if btn == 1 then
        self._private.popup():show(self._private.screen, self._private.placement)
    elseif btn == 3 then
    elseif btn == 4 then
    elseif btn == 5 then
    end
end

function clock.new(args)
    args.widget = wibox.widget {
        format = args.format,
        font = args.font,
        widget = wibox.widget.textclock
    }
    args.popup = calendar

    local ret = button(args)

    ret:connect_signal("button::press", on_press)
    return ret
end

function clock.mt:__call(...)
    return clock.new(...)
end

return setmetatable(clock, clock.mt)
