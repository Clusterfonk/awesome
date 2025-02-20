-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local awful = require("awful")
local wibox = require("wibox")
local bt = require("beautiful")
local gtable = require("gears.table")
local dpi = bt.xresources.apply_dpi

local base = require("ui.popups.base")


-- TODO: when nothing in systray then
-- check for  entries = awesomewm.systray()
-- entries > 0 or maybe show an empty systray
systray = { mt = {} }

-- might need to be able to switch screens
function systray.new(args)
    args.widget = wibox.widget {
        {
            {
                widget = wibox.widget.systray, -- TODO: should be singleton for every screen
                reverse = true,
                base_size = args.height - 2 * dpi(2, args.screen),
                screen = awful.screen.primary
            },
            widget = wibox.container.place,
            valign = "center",
            halign = "right"
        },
        widget = wibox.container.margin,
        left = bt.useless_gap,
        right = bt.useless_gap,
        top = 1,
        bottom = 1,
    }
    local ret = base(args)

    gtable.crush(ret, systray, true)
    return ret
end

function systray.mt:__call(...)
    return systray.new(...)
end

return setmetatable(systray, systray.mt)
