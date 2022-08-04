-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local bt = require("beautiful")


-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

-- Change border_color of the focused client
client.connect_signal("focus", function(c) c.border_color = bt.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = bt.border_normal end)
