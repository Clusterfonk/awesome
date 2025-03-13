-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local awful = require("awful")

capi = {
    tag = tag
}

capi.tag.connect_signal("request::default_layouts", function()
	awful.layout.append_default_layouts({
        awful.layout.suit.tile,
        awful.layout.suit.fair.horizontal,
        awful.layout.suit.floating,
	})
end)
