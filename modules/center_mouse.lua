-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local awful = require("awful")


awesome.connect_signal("startup", function()
    local s = screen.primary
    awful.screen.focus(s)
    awful.placement.centered(mouse, s)
end)
