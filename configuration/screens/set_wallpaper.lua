-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local awful = require("awful")
local wibox = require("wibox")
local bt = require("beautiful")

local capi = {
    screen = screen
}

-- setting the same wallpaper for every screen added/changed
capi.screen.connect_signal("request::wallpaper", function(s)
    awful.wallpaper {
        screen = s,
        widget = {
            image = bt.wallpaper,
            horizontal_fit_policy = "fit",
            vertical_fit_policy = "fit",
            widget = wibox.widget.imagebox,
        }
    }
end)
