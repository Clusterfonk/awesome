-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local awful = require("awful")


local capi = {
    awesome = awesome,
    screen = screen
}

capi.awesome.connect_signal("startup", function()
    local s = capi.screen.primary
    awful.screen.focus(s)
    awful.placement.centered(mouse, s)
end)
