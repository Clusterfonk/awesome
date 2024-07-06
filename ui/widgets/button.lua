-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local wibox = require("wibox")
local gtable = require("gears.table")

local button = { mt = {} }


local function on_hover(self, ...)
    print("hover over button")
end

local function on_press(self, lx, ly, btn, mode, mods)
    if btn == 1 then
        print(self)
    end
end

local function new(args)
    local widget = wibox.container.background {
        widget = wibox.container.margin
    }
    gtable.crush(widget, button, true)

    widget:connect_signal("mouse::enter",
        function()
        on_hover(widget)
        args:on_enter()
    end)
    widget:connect_signal("button::press", on_press)

    return widget
end

function button.mt:__call(...)
    return new(...)
end

return setmetatable(button, button.mt)
