-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local bt = require("beautiful")

local capi = {
    client = client
}


-- Enable sloppy focus, so that focus follows mouse.
capi.client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

-- Change border_color of the focused client
capi.client.connect_signal("focus", function(c) c.border_color = bt.border_focus end)
capi.client.connect_signal("unfocus", function(c) c.border_color = bt.border_normal end)

